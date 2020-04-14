//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

final class SetupAndroid: SetupDefault {
    
    // --------------
    // MARK: Command information
    
    override var name: String {
        get { "android" }
        set { }
    }
    
    override var shortDescription: String {
        get { "Setup multiple build flavours for Android project, alongside fastlane" }
        set { }
    }
    
    override func createVariants(for environments: [Environment]) {
        log("Creating build flavour for environments:")
        environments.forEach {
            log("→ \($0.env)\n", indentationLevel: 1, color: .android)
        }
    }
}
