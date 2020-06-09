//
//  Variants
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
    
    override func execute() throws {
        platform = .android
        
        log("--------------------------------------------", force: true)
        log("Running: mobile-setup android", force: true)
        log("--------------------------------------------\n", force: true)
        
        try super.execute()
    }
    
    override func createVariants(for variants: [Variant]?) {
        log("Creating build flavour for variants:")
        variants?.compactMap { $0 }.forEach {
            log("→ \($0.name)\n", indentationLevel: 1, color: .android)
        }
    }
}
