//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation

public struct AndroidConfiguration: Codable {
    let path: String
    let appName: String
    let appIdentifier: String
    let variants: [AndroidVariant]
    let signing: AndroidSigning?
    let custom: [CustomProperty]?

    enum CodingKeys: String, CodingKey {
        case path = "path"
        case appName = "app_name"
        case appIdentifier = "app_identifier"
        case variants = "variants"
        case signing = "signing"
        case custom = "custom"
    }
}
