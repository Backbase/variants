//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

// swiftlint:disable type_name

import Foundation

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

// swiftlint:enable type_name
