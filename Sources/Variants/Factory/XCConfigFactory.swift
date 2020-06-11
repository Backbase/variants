//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

public typealias DoesFileExist = (exists: Bool, path: Path?)

struct XCConfigFactory {
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
    
    func writeJSON<T>(_ encodableObject: T, toFile file: Path) -> (Bool, Path?) where T : Encodable {
        let encoder = JSONEncoder()
        if #available(OSX 10.15, *) {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        } else {
            encoder.outputFormatting = .prettyPrinted
        }
        
        do {
            try Task.run(bash: "touch \(file.absolute().description)")
            
            let encoded = try encoder.encode(encodableObject)
            guard let encodedJSONString = String(data: encoded, encoding: .utf8) else { return (false, nil) }
            try encodedJSONString.write(toFile: file.absolute().description, atomically: true, encoding: .utf8)
            
            return (true, file)
            
        } catch {
            return (false, nil)
        }
    }
    
    func createConfig(with target: NamedTarget,
                      variant: Variant,
                      xcodeProj: String?,
                      configPath: Path,
                      addToXcodeProj: Bool? = true) {
        
        let logger = Logger.shared
        guard let xcodeProj = xcodeProj
        else {
            logger.logFatal("❌ ", item: "Attempting to create variants.xcconfig - Path to Xcode Project not found")
            return
        }
        let xcodeProjPath = Path(xcodeProj)
        
        let configString = target.value.source.config
        
        logger.logInfo(item: "Checking if variants.xcconfig exists")
        let xcodeConfigFolder = Path("\(configPath)/\(configString)")
        guard xcodeConfigFolder.isDirectory else {
            logger.logFatal("❌ ", item: "'\(xcodeConfigFolder.absolute().description)' doesn't exist or isn't a folder")
            return
        }

        let xcodeConfigPath = Path("\(xcodeConfigFolder.absolute().description)/Variants/variants.xcconfig")
        if !xcodeConfigPath.parent().isDirectory {
            logger.logDebug(item: "Creating folder '\(xcodeConfigPath.parent().description)'")
            try? Task.run("mkdir", xcodeConfigPath.parent().absolute().description)
        }
        
        let _ = write("", toFile: xcodeConfigPath, force: true)
        logger.logDebug(item: "Created file: 'variants.xcconfig' at \(xcodeConfigPath.parent().absolute().description)")
        
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
    
    func doesTemplateExist() -> DoesFileExist {
        var path: Path?
        var exists = true
        
        let libTemplates = Path("/usr/local/lib/variants/templates")
        let localTemplates = Path("./Templates")
        
        if libTemplates.exists {
            path = libTemplates
        } else if localTemplates.exists {
            path = localTemplates
        } else {
            exists = false
        }
        
        return (exists: exists, path: path)
    }
    
    // MARK: - Convert method
    
    private func addToXcode(_ xcConfigFile: Path,
                            toProject projectPath: Path,
                            sourceRoot: Path,
                            target: NamedTarget) {
        let result = XCConfigFactory().doesTemplateExist()
        let variantsFile = Path("\(xcConfigFile.parent().absolute().description)/Variants.swift")
        
        guard result.exists, let path = result.path, path.exists
        else {
            Logger.shared.logFatal("❌ ", item: "Templates folder not found on '/usr/local/lib/variants/templates' or './Templates'")
            return
        }
        
        do {
            try Task.run(bash: "cp \(path.absolute())/ios/Variants.swift \(variantsFile.absolute().description)", directory: nil)
            
            let xcodeFactory = XcodeProjFactory()
            xcodeFactory.add([xcConfigFile, variantsFile], toProject: projectPath, sourceRoot: sourceRoot, target: target)
            
            xcodeFactory.modify(
                [
                    "PRODUCT_BUNDLE_IDENTIFIER": "$(V_BUNDLE_ID)",
                    "PRODUCT_NAME": "$(V_APP_NAME)",
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "$(V_APP_ICON)",
                ],
                in: projectPath,
                target: target.value)
            
        } catch {
            Logger.shared.logError("❌ ", item: "Failed to add Variants.swift to Xcode Project")
        }
    }
    
    private func populateConfig(with target: Target, configFile: Path, variant: Variant) {
        Logger.shared.logDebug(item: "Populating .xcconfig")
        variant.getDefaultValues(for: target).forEach { (key, value) in
            let stringContent = "\(key) = \(value)"
            Logger.shared.logDebug("Item: ", item: stringContent, indentationLevel: 1, color: .purple)
            
            let (success, _) = write(stringContent, toFile: configFile, force: false)
            if !success {
                Logger.shared.logDebug("⚠️  ", item: "Failed to add item to .xcconfig", indentationLevel: 2)
            }
        }
    }
    
    private func updateInfoPlist(with target: Target, configFile: Path, variant: Variant) {
        
        do {
            try Task.run(bash: "plutil -replace CFBundleVersion -string '$(V_VERSION_NUMBER)' \(configFile.absolute().description)")
            try Task.run(bash: "plutil -replace CFBundleShortVersionString -string '$(V_VERSION_NAME)' \(configFile.absolute().description)")
            try Task.run(bash: "plutil -replace CFBundleName -string '$(V_APP_NAME)' \(configFile.absolute().description)")
            try Task.run(bash: "plutil -replace CFBundleExecutable -string '$(V_APP_NAME)' \(configFile.absolute().description)")
            try Task.run(bash: "plutil -replace CFBundleIdentifier -string '$(V_BUNDLE_ID)' \(configFile.absolute().description)")
            
            /*
             * Add custom configs to Info.plist so that it is accessible through Variants.swift
             */
            try variant.getDefaultValues(for: target).filter { !$0.key.starts(with: "V_") }
                .forEach { (key, _) in
                    try? Task.run(bash: "plutil -remove '$(\(key))' \(configFile.absolute().description)")
                    try Task.run(bash: "plutil -insert '$(\(key))' -string '$(\(key))' \(configFile.absolute().description)")
            }
            
        } catch {
            Logger.shared.logFatal("❌ ", item: "Something went wrong while updating the Info.plist")
        }
    }
}
