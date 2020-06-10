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
            let defaultVariant = variants.first(where: { $0.name == "default" })
        else {
            logger.logError("❌ ", item: "Missing mandatory variant 'default'")
            exit(1)
        }
        
        let configPath = Path(defaultSpecs).absolute().parent()
        factory.createConfig(with: target, variant: defaultVariant, pbxproj: pbxproj, configPath: configPath)
        
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
}
