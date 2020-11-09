//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import ArgumentParser
import PathKit

public typealias DoesFileExist = (exists: Bool, path: Path?)

protocol XCFactory {
    func write(_ stringContent: String, toFile file: Path, force: Bool) -> (Bool, Path?)
    func writeJSON<T>(_ encodableObject: T, toFile file: Path) -> (Bool, Path?) where T: Encodable
    func createConfig(with target: NamedTarget,
                      variant: iOSVariant,
                      xcodeProj: String?,
                      configPath: Path,
                      addToXcodeProj: Bool?)
}

class XCConfigFactory: XCFactory {
    init(logLevel: Bool = false) {
        logger = Logger(verbose: logLevel)
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
    
    func createConfig(with target: NamedTarget,
                      variant: iOSVariant,
                      xcodeProj: String?,
                      configPath: Path,
                      addToXcodeProj: Bool? = true) {
        
        let logger = Logger.shared
        guard let xcodeProj = xcodeProj
        else {
            logger.logFatal("❌ ", item: "Attempting to create \(xcconfigFileName) - Path to Xcode Project not found")
            return
        }
        let xcodeProjPath = Path(xcodeProj)
        
        let configString = target.value.source.config
        
        logger.logInfo("Checking if \(xcconfigFileName) exists", item: "")
        let xcodeConfigFolder = Path("\(configPath)/\(configString)")
        guard xcodeConfigFolder.isDirectory else {
            logger.logFatal("❌ ", item: "'\(xcodeConfigFolder.absolute().description)' doesn't exist or isn't a folder")
            return
        }

        let xcodeConfigPath = Path("\(xcodeConfigFolder.absolute().description)/Variants/\(xcconfigFileName)")
        if !xcodeConfigPath.parent().isDirectory {
            logger.logInfo("Creating folder: ", item: "'\(xcodeConfigPath.parent().description)'")
            _ = try? Bash("mkdir", arguments: xcodeConfigPath.parent().absolute().description).run()
        }
        
        _ = write("", toFile: xcodeConfigPath, force: true)
        logger.logInfo("Created file: ", item: "'\(xcconfigFileName)' at \(xcodeConfigPath.parent().abbreviate().description)")
        
        populateConfig(with: target.value, configFile: xcodeConfigPath, variant: variant)
        
        /*
         * If template files should be added to Xcode Project
         */
        if addToXcodeProj ?? false {
            addToXcode(xcodeConfigPath, toProject: xcodeProjPath, sourceRoot: configPath, target: target)
        }
        
        /*
         * INFO.plist
         */
        let infoPath = target.value.source.info
        let infoPlistPath = Path("\(configPath)/\(infoPath)")
        
        updateInfoPlist(with: target.value, configFile: infoPlistPath, variant: variant)
    }
    
    // MARK: - Private methods
    
    private func addToXcode(_ xcConfigFile: Path,
                            toProject projectPath: Path,
                            sourceRoot: Path,
                            target: NamedTarget) {
        let variantsFile = Path("\(xcConfigFile.parent().absolute().description)/Variants.swift")

        do {
            let path = try TemplateDirectory().path
            try Bash("cp", arguments:
                "\(path.absolute())/ios/Variants.swift",
                variantsFile.absolute().description
            ).run()
            
            let xcodeFactory = XcodeProjFactory()
            xcodeFactory.add([xcConfigFile, variantsFile], toProject: projectPath, sourceRoot: sourceRoot, target: target)
            
            xcodeFactory.modify(
                [
                    "PRODUCT_BUNDLE_IDENTIFIER": "$(V_BUNDLE_ID)",
                    "PRODUCT_NAME": "$(V_APP_NAME)",
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "$(V_APP_ICON)"
                ],
                in: projectPath,
                target: target.value)
            
        } catch {
            logger.logError("❌ ", item: "Failed to add Variants.swift to Xcode Project")
        }
    }
    
    private func populateConfig(with target: iOSTarget, configFile: Path, variant: iOSVariant) {
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
    
    private func updateInfoPlist(with target: iOSTarget, configFile: Path, variant: iOSVariant) {
        
        let configFilePath = configFile.absolute().description
        do {
            // TODO: Add plutil as separate command?
            let commands = [
                Bash("plutil", arguments: "-replace", "CFBundleVersion", "-string", "'$(V_VERSION_NUMBER)'", configFilePath),
                Bash("plutil", arguments: "-replace", "CFBundleShortVersionString", "-string", "'$(V_VERSION_NAME)'", configFilePath),
                Bash("plutil", arguments: "-replace", "CFBundleName", "-string", "'$(V_APP_NAME)'", configFilePath),
                Bash("plutil", arguments: "-replace", "CFBundleExecutable", "-string", "'$(V_APP_NAME)'", configFilePath),
                Bash("plutil", arguments: "-replace", "CFBundleIdentifier", "-string", "'$(V_BUNDLE_ID)'", configFilePath)
            ]
            
            try commands.forEach { try $0.run() }
            
            /*
             * Add custom configs to Info.plist so that it is accessible through Variants.swift
             */
            try variant
                .getDefaultValues(for: target)
                .filter { !$0.key.starts(with: "V_") }
                .forEach { (key, _) in
                    try Bash("plutil", arguments: "-remove '\(key)'", configFilePath).run()
                    try Bash("plutil", arguments: "-insert '\(key)'", "-string '$(\(key))'", configFilePath).run()
            }
            
        } catch {
            logger.logDebug(item: (error as NSError).debugDescription)
            logger.logFatal("❌ ", item: "Something went wrong while updating the Info.plist")
        }
    }
    
    let xcconfigFileName: String = "variants.xcconfig"
    let logger: Logger
}
