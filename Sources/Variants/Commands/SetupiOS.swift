//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

final class SetupiOS: SetupDefault {
    
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
        
        log("--------------------------------------------", force: true)
        log("Running: mobile-setup ios", force: true)
        log("--------------------------------------------\n", force: true)
        
        try super.execute()
    }
    
    override func createVariants(for variants: [Variant]?) {
        log("Creating xcconfig for variants:")
        variants?.compactMap { $0 }.forEach {
            log("→ \($0.name)\n", indentationLevel: 1, color: .ios)
        }
    }
}
