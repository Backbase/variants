//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

enum ConfigurationParserError: Error {
    case platformNotFound(_ platform: Platform)
    case variantNotFound(_ variant: String, platform: Platform)
    
    var message: String {
        switch self {
        case .platformNotFound(let platform):
            return "Configuration for platform '\(platform)' not found in 'variants.yml'"
        case .variantNotFound(let variant, platform: let desiredPlatform):
            return "Variant \(variant) not found not found for \(desiredPlatform)"
        }
    }
}
