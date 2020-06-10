//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

final class iOSSetup: SetupDefault {
    
    let factory = XCConfigFactory()
    
    // --------------
    // MARK: Command information
    
    override var name: String {
        get { "ios" }
        set(newValue) { }
    }
    
    override var shortDescription: String {
        get { "Setup multiple xcconfigs for iOS project, alongside fastlane" }
        set(newValue) { }
    }
    
    override func execute() throws {
        platform = .ios
        try super.execute()
    }
    
    override func createConfig(with target: Target, variants: [Variant]?, pbxproj: String?) {
        guard
            let variants = variants,
            !variants.isEmpty,
            variants.first(where: { $0.name == "default" }) != nil
        else {
            logger.logError("❌ ", item: "Missing mandatory variant 'default'")
            exit(1)
        }
        
        logger.logDebug(item: "Checking if mobile-variants.xcconfig exists")
        
        guard let parentString = configuration else  { return }
        let configPath = Path(parentString).absolute().parent()
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
        
        let _ = factory.write("", toFile: xcodeConfigPath, force: true)
        logger.logDebug(item: "Created file: 'mobile-variants.xcconfig' at \(xcodeConfigFolder.absolute().description)")
        
        guard let variant = variants.first else {
            Logger.shared.logError("❌ ", item: "Variants not specified")
            return
        }
        factory.populateConfig(with: target, configFile: xcodeConfigPath, variant: variant)
        
        /*
         * INFO.plist
         */
        let infoPath = target.source.info
        let infoPlistPath = Path("\(configPath)/\(infoPath)")
        
        updateInfoPlist(with: target, configFile: infoPlistPath, variant: variant)
        
        /*
         * PBXPROJ
         * TODO: Edit pbxproj to modify, if needed:
         *      - ASSETCATALOG_COMPILER_APPICON_NAME
         *      - PRODUCT_BUNDLE_IDENTIFIER
         *      - PROVISIONING_PROFILE_SPECIFIER
         */
        /*
        guard let pbxString = pbxproj else { return }
        let pbxPath = Path("\(configPath)/\(pbxString)")
        factory.convertPBXToJSON(pbxPath)
        */
    }
    
    // MARK: - Private
    
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
                    try? Task.run(bash: "plutil -remove \(key) \(configFile.absolute().description)")
                    try Task.run(bash: "plutil -insert '$(\(key))' -string '$(\(key))' \(configFile.absolute().description)")
            }
            
        } catch {
            logger.logError("❌ ", item: error.localizedDescription)
            exit(1)
        }
    }
}
