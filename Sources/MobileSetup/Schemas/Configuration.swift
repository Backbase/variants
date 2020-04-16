//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

public struct Configuration: Codable {
    let name: String
    let targets: [String: Target]
    let setupConfiguration: SetupConfiguration
}

public struct SetupConfiguration: Codable {
    let configPath: String
    let baseBundleId: String
    let environments: [Environment]
}

public struct Target: Codable {
    let sources: [Source]
}

public struct Source: Codable {
    let path: String
}

