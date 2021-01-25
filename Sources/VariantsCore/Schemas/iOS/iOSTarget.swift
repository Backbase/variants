//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

// swiftlint:disable type_name

public typealias NamedTarget = (key: String, value: iOSTarget)

public struct iOSTarget: Codable {
    let name: String
    let app_icon: String
    let bundleId: String
    let testTarget: String
    let source: iOSSource
    
    enum CodingKeys: String, CodingKey {
        case name
        case app_icon
        case bundleId = "bundle_id"
        case testTarget = "test_target"
        case source
    }
}

public struct iOSSource: Codable {
    let path: String
    let info: String
    let config: String
}
