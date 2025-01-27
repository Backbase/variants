//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

// swiftlint:disable file_length

import Foundation
import ArgumentParser
import PathKit
import Stencil

public typealias DoesFileExist = (exists: Bool, path: Path?)

protocol XCFactory {
    func write(_ stringContent: String, toFile file: Path, force: Bool) -> (Bool, Path?)
    func writeJSON<T>(_ encodableObject: T, toFile file: Path) -> (Bool, Path?) where T: Encodable
    func createConfig(for variant: iOSVariant, configuration: iOSConfiguration, configPath: Path) throws
}

class XCConfigFactory: XCFactory {
    init(logger: Logger = Logger(verbose: false)) {
        self.logger = logger
    }
    
    func write(_ stringContent: String, toFile file: Path, force: Bool) -> (Bool, Path?) {
        do {
            if force {
                try stringContent.write(toFile: file.absolute().description,
                                        atomically: false,
                                        encoding: .utf8)
            } else {
                try stringContent.appendLine(to: file)
            }
            return (true, file)
        } catch {
            return (false, nil)
        }
    }
    
    func writeJSON<T>(_ encodableObject: T, toFile file: Path) -> (Bool, Path?) where T: Encodable {
        let encoder = JSONEncoder()
        if #available(OSX 10.15, *) {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        } else {
            encoder.outputFormatting = .prettyPrinted
        }
        
        do {
            try Bash("touch", arguments: file.absolute().description).run()
            
            let encoded = try encoder.encode(encodableObject)
            guard let encodedJSONString = String(data: encoded, encoding: .utf8) else { return (false, nil) }
            try encodedJSONString.write(toFile: file.absolute().description, atomically: true, encoding: .utf8)
            
            return (true, file)
        } catch {
            return (false, nil)
        }
    }
    
    func createConfig(for variant: iOSVariant, configuration: iOSConfiguration, configPath: Path) throws {
        let logger = Logger.shared
        let xcodeProjPath = Path(configuration.xcodeproj)
        let configString = configuration.target.source.config

        logger.logInfo("Checking if \(xcconfigFileName) exists", item: "")
        let xcodeConfigFolder = Path("\(configPath)/\(configString)")
        guard xcodeConfigFolder.isDirectory else {
            throw RuntimeError("'\(xcodeConfigFolder.absolute().description)' doesn't exist or isn't a folder")
        }

        let xcodeConfigPath = Path("\(xcodeConfigFolder.absolute().description)/Variants/\(xcconfigFileName)")
        if !xcodeConfigPath.parent().isDirectory {
            logger.logInfo("Creating folder: ", item: "'\(xcodeConfigPath.parent().description)'")
            _ = try? Bash("mkdir", arguments: xcodeConfigPath.parent().absolute().description).run()
        }
        
        _ = write("", toFile: xcodeConfigPath, force: true)
        logger.logInfo("Created file: ", item: "'\(xcconfigFileName)' at \(xcodeConfigPath.parent().abbreviate().description)")
        populateConfig(for: configuration.target, configFile: xcodeConfigPath, variant: variant)

        /*
         * If template files should be added to Xcode Project
         */
        addToXcode(xcodeConfigPath, toProject: xcodeProjPath, sourceRoot: configPath, variant: variant, configuration: configuration)

        /*
         * Adjust signing configuration in project.pbxproj
         */
        updateSigningConfig(for: variant, configuration: configuration, projectPath: xcodeProjPath)
        updateSigningConfigForExtensions(for: variant, configuration: configuration, projectPath: xcodeProjPath)

        /*
         * INFO.plist
         */
        let infoPath = configuration.target.source.info
        let infoPlistPath = Path("\(configPath)/\(infoPath)")
        updateInfoPlist(with: configuration.target, configFile: infoPlistPath, variant: variant)

        /*
         * Add custom properties whose values should be read from environment variables
         * to `Variants.Secret` as encrypted secrets.
         */
        let variantsFileFactory = VariantsFileFactory(logger: logger)
        variantsFileFactory.updateVariantsFile(with: xcodeConfigPath, variant: variant)
    }
    
    // MARK: - Private methods
    
    private func addToXcode(_ xcConfigFile: Path,
                            toProject projectPath: Path,
                            sourceRoot: Path,
                            variant: iOSVariant,
                            configuration: iOSConfiguration) {
        let variantsFile = Path("\(xcConfigFile.parent().absolute().description)/Variants.swift")
        do {
            let path = try TemplateDirectory().path
            try Bash("cp", arguments:
                "\(path.absolute())/ios/Variants.swift",
                variantsFile.absolute().description
            ).run()
            
            let xcodeFactory = XcodeProjFactory()
            xcodeFactory.add([xcConfigFile, variantsFile], toProject: projectPath, sourceRoot: sourceRoot, target: configuration.target)

            // Update main target
            let mainTargetSettings = [
                "PRODUCT_BUNDLE_IDENTIFIER": "$(V_BUNDLE_ID)",
                "PRODUCT_NAME": "$(V_APP_NAME)",
                "ASSETCATALOG_COMPILER_APPICON_NAME": "$(V_APP_ICON)"
            ]
            xcodeFactory.modify(mainTargetSettings, in: projectPath, targetName: configuration.target.source.info)

            // Update test target
            let testTargetSettings = [
                "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/$(V_APP_NAME).app/$(V_APP_NAME)"
            ]
            xcodeFactory.modify(testTargetSettings, in: projectPath, targetName: configuration.target.testTarget)

            // Update extensions
            for targetExtension in configuration.extensions.filter({ $0.signed }) {
                let bundleID = targetExtension.makeBundleID(variant: variant, target: configuration.target)
                let extensionSettings = [
                    "PRODUCT_BUNDLE_IDENTIFIER": "\(bundleID)"
                ]
                xcodeFactory.modify(extensionSettings, in: projectPath, targetName: targetExtension.name)
            }

        } catch {
            logger.logError("❌ ", item: "Failed to add Variants.swift to Xcode Project")
        }
    }

    private func populateConfig(for target: iOSTarget, configFile: Path, variant: iOSVariant) {
        logger.logInfo("Populating: ", item: "'\(configFile.lastComponent)'")
        variant.getDefaultValues(for: target).forEach { (key, value) in
            let stringContent = "\(key) = \(value)"
            logger.logDebug("Item: ", item: stringContent, indentationLevel: 1, color: .purple)
            
            let (success, _) = write(stringContent, toFile: configFile, force: false)
            if !success {
                logger.logWarning(item: "Failed to add item to .xcconfig", indentationLevel: 2)
            }
        }
    }

    private func updateSigningConfig(
        for variant: iOSVariant,
        configuration: iOSConfiguration,
        projectPath: Path
    ) {
        guard
            let exportMethod = variant.signing?.exportMethod,
            let teamName = variant.signing?.teamName,
            let teamID = variant.signing?.teamID,
            !teamID.isEmpty,
            !teamName.isEmpty
        else { return }

        let isDistribution = exportMethod == .appstore || exportMethod == .enterprise
        let certType = isDistribution ? "Distribution" : "Development"
        let signingSettings = [
            "PROVISIONING_PROFILE_SPECIFIER": "$(V_MATCH_PROFILE)",
            "CODE_SIGN_STYLE": "Manual",
            "CODE_SIGN_IDENTITY": "Apple \(certType): \(teamName) (\(teamID))"
        ]

        let xcodeFactory = XcodeProjFactory()
        xcodeFactory.modify(signingSettings, in: projectPath, targetName: configuration.target.source.info)
    }

    private func updateSigningConfigForExtensions(
        for variant: iOSVariant,
        configuration: iOSConfiguration,
        projectPath: Path
    ) {
        let targetExtensions = configuration.extensions.filter({ $0.signed })
        guard 
            !targetExtensions.isEmpty,
            let exportMethod = variant.signing?.exportMethod,
            let teamName = variant.signing?.teamName,
            let teamID = variant.signing?.teamID,
            !teamID.isEmpty,
            !teamName.isEmpty
        else { return }

        let isDistribution = exportMethod == .appstore || exportMethod == .enterprise
        let certType = isDistribution ? "Distribution" : "Development"

        let xcodeFactory = XcodeProjFactory()
        for targetExtension in targetExtensions {
            let bundleID = targetExtension.makeBundleID(variant: variant, target: configuration.target)
            let signingSettings = [
                "PROVISIONING_PROFILE_SPECIFIER": "\(exportMethod.prefix) \(bundleID)",
                "CODE_SIGN_STYLE": "Manual",
                "CODE_SIGN_IDENTITY": "Apple \(certType): \(teamName) (\(teamID))"
            ]
            xcodeFactory.modify(signingSettings, in: projectPath, targetName: targetExtension.name)
        }
    }

    private func updateInfoPlist(with target: iOSTarget, configFile: Path, variant: iOSVariant) {
        let configFilePath = configFile.absolute().description
        do {
            // TODO: Add plutil as separate command?
            let commands = [
                Bash("plutil", arguments: "-replace", "CFBundleVersion", "-string", "$(V_VERSION_NUMBER)", configFilePath),
                Bash("plutil", arguments: "-replace", "CFBundleShortVersionString", "-string", "$(V_VERSION_NAME)", configFilePath),
                Bash("plutil", arguments: "-replace", "CFBundleName", "-string", "$(V_APP_NAME)", configFilePath),
                Bash("plutil", arguments: "-replace", "CFBundleDisplayName", "-string", "$(V_APP_NAME)", configFilePath),
                Bash("plutil", arguments: "-replace", "CFBundleExecutable", "-string", "$(V_APP_NAME)", configFilePath),
                Bash("plutil", arguments: "-replace", "CFBundleIdentifier", "-string", "$(V_BUNDLE_ID)", configFilePath)
            ]
            
            try commands.forEach { try $0.run() }
            
            /*
             * Add custom configs to Info.plist so that it is accessible through Variants.swift
             */
            try variant
                .getDefaultValues(for: target)
                .filter { !$0.key.starts(with: "V_") }
                .forEach { (key, _) in
                    try Bash("plutil", arguments: "-remove", "\(key)", configFilePath).run()
                    try Bash("plutil", arguments: "-insert", "\(key)", "-string", "$(\(key))", configFilePath).run()
            }
            
        } catch {
            logger.logDebug(item: (error as NSError).debugDescription)
            logger.logFatal("❌ ", item: "Something went wrong while updating the Info.plist")
        }
    }
    
    let xcconfigFileName: String = "variants.xcconfig"
    let logger: Logger
}

// swiftlint:enable file_length
