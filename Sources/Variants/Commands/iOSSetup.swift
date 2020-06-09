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
        logger.logDebug(item: "Checking if mobile-variants.xcconfig exists")
        
        guard let parentString = configuration else  { return }
        let configPath = Path(parentString).absolute().parent()
        let configString = target.source.config
        
        let xcodeConfigFolder = Path("\(configPath)/\(configString)")
        guard xcodeConfigFolder.isDirectory else {
            logger.logError("❌: ", item: "'\(xcodeConfigFolder.absolute().description)' doesn't exist or isn't a folder")
            return
        }

        let xcodeConfigPath = Path("\(xcodeConfigFolder.absolute().description)/mobile-variants.xcconfig")
        if !xcodeConfigPath.isFile {
            logger.logDebug(item: "mobile-variants.xcconfig already exist. Cleaning up")
        }
        
        factory.write("", toFile: xcodeConfigPath, force: true)
        logger.logDebug(item: "Created file: 'mobile-variants.xcconfig' at \(xcodeConfigFolder.absolute().description)")
        
        factory.populateConfig(with: target, configFile: xcodeConfigPath, variants: variants)
        
        /*
         * INFO.plist
         */
        let infoPath = target.source.info
        let infoPlistPath = Path("\(configPath)/\(infoPath)")
        
        updateInfoPlist(with: target, configFile: infoPlistPath, variants: variants)
        
        /*
         * PBXPROJ
         */
        guard
            let pbxString = pbxproj,
            let pbxPath: Path = Path("\(configPath)/\(pbxString)"),
            pbxPath.exists
        else { return }
        factory.convertPBXToJSON(pbxPath)
    }
    
    // MARK: - Private
    
    private func updateInfoPlist(with target: Target, configFile: Path, variants: [Variant]?) {
        
        do {
            try Task.run(bash: "plutil -replace CFBundleVersion -string '$(MV_VERSION_NUMBER)' \(configFile.absolute().description)")
            
            try Task.run(bash: "plutil -replace CFBundleShortVersionString -string '$(MV_VERSION_NAME)' \(configFile.absolute().description)")
            
            try Task.run(bash: "plutil -replace CFBundleName -string '$(MV_APP_NAME)' \(configFile.absolute().description)")
            
            try Task.run(bash: "plutil -replace CFBundleExecutable -string '$(MV_APP_NAME)' \(configFile.absolute().description)")
            
            try Task.run(bash: "plutil -replace CFBundleIdentifier -string '$(MV_BUNDLE_ID)' \(configFile.absolute().description)")
            
        } catch {
            logger.logError("❌: ", item: error.localizedDescription)
            exit(1)
        }
    }
}
