//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

public struct Configuration: Codable, Classable {
    static let _class = "config"

    let name: String
    let targets: [String: Target]
    let setupConfiguration: SetupConfiguration
}

public struct SetupConfiguration: Codable, Classable {
    static let _class = "setupConfiguration"
    
    let configPath: String
    let baseBundleId: String
    let environments: [Environment]
}

public struct Target: Codable, Classable {
    static let _class = "target"
    
    let sources: [Source]
}

public struct Source: Codable, Classable {
    static let _class = "source"
    
    let path: String
}

