//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

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
    
    func createConfig(with target: Target, variant: Variant, xcodeProj: String?, configPath: Path) {
        let logger = Logger.shared
        logger.logDebug(item: "Checking if mobile-variants.xcconfig exists")
        
        let configString = target.source.config
        
        let xcodeConfigFolder = Path("\(configPath)/\(configString)")
        guard xcodeConfigFolder.isDirectory else {
            logger.logError("❌ ", item: "'\(xcodeConfigFolder.absolute().description)' doesn't exist or isn't a folder")
            return
        }

        let xcodeConfigPath = Path("\(xcodeConfigFolder.absolute().description)/mobile-variants.xcconfig")
        if !xcodeConfigPath.isFile {
            logger.logDebug(item: "mobile-variants.xcconfig already exist. Cleaning up")
        }
        
        let _ = write("", toFile: xcodeConfigPath, force: true)
        logger.logDebug(item: "Created file: 'mobile-variants.xcconfig' at \(xcodeConfigFolder.absolute().description)")
        
        populateConfig(with: target, configFile: xcodeConfigPath, variant: variant)
        
        /*
         * INFO.plist
         */
        let infoPath = target.source.info
        let infoPlistPath = Path("\(configPath)/\(infoPath)")
        
        updateInfoPlist(with: target, configFile: infoPlistPath, variant: variant)
        
        let xcodeFactory = XcodeProjFactory()
        xcodeFactory.modify(
            [
                "PRODUCT_BUNDLE_IDENTIFIER": "$(V_BUNDLE_ID)",
                "PRODUCT_NAME": "$(V_APP_NAME)",
            ],
            in: Path(xcodeProj!),
            target: target)
    }
    
    // MARK: - Convert method
    
    private func populateConfig(with target: Target, configFile: Path, variant: Variant) {
        Logger.shared.logDebug(item: "Populating .xcconfig")
        variant.getDefaultValues(for: target).forEach { (key, value) in
            let stringContent = "\(key) = \(value)"
            Logger.shared.logDebug("Item: ", item: stringContent, indentationLevel: 1, color: .purple)
            
            let (success, _) = write(stringContent, toFile: configFile, force: false)
            if !success {
                Logger.shared.logDebug("⚠️ ", item: "Failed to add item to .xcconfig", indentationLevel: 2)
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
            Logger.shared.logError("❌ ", item: "Something went wrong while updating the Info.plist")
            exit(1)
        }
    }
    
    private func convertPBXToJSON(_ config: Path) {
        do {
            Logger.shared.logDebug(item: "Converting project.pbxproj to JSON")
            try Task.run(bash: "plutil -convert json \(config.absolute().description)")
        } catch {
            Logger.shared.logError("❌ ", item: error.localizedDescription)
        }
    }
}
