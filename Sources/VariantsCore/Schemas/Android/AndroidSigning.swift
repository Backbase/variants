//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation

public struct AndroidSigning: Codable {
    let keyAlias: String
    let keyPassword: String
    let storeFile: String
    let storePassword: String
    
    enum CodingKeys: String, CodingKey {
        case keyAlias = "key_alias"
        case keyPassword = "key_password"
        case storeFile = "store_file"
        case storePassword = "store_password"
    }
}
