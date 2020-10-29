//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Balazs Toth
//

import Foundation

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = "❌ "+description
    }
    
    static let unableToInitializeVariants = RuntimeError("Unable to initialize variants - Check your YAML spec")
    static let unableToSetupVariants = RuntimeError("Unable to setup variants - Check your YAML spec")
    static let unableToSwitchVariants = RuntimeError("Unable to switch variants - Check your YAML spec")
}
