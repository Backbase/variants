//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

final class AndroidSetup: SetupDefault {
    
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
        try super.execute()
    }
}
