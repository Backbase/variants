//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

public typealias NamedTarget = (key: String, value: iOSTarget)

public struct iOSTarget: Codable {
    let name: String
    let bundleId: String
    let app_icon: String
    let source: iOSSource
    
    enum CodingKeys: String, CodingKey {
        case name
        case app_icon
        case bundleId = "bundle_id"
        case source
    }
}

public struct iOSSource: Codable {
    let path: String
    let info: String
    let config: String
}
