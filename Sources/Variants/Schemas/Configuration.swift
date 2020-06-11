//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

public struct Configuration: Codable {
    let ios: iOSConfiguration?
    let android: AndroidConfiguration?
}

public protocol BaseConfiguration {
    var targets: [String: Target] { get }
    var variants: [Variant] { get }
}

public struct iOSConfiguration: Codable, BaseConfiguration {
    public var xcodeproj: String
    public var targets: [String: Target]
    public var variants: [Variant]
    
    var pbxproj: String {
        return xcodeproj+"/project.pbxproj"
    }
}

public struct AndroidConfiguration: Codable, BaseConfiguration {
    public var targets: [String : Target]
    public var variants: [Variant]
}

public typealias NamedTarget = (key: String, value: Target)
public struct Target: Codable {
    let name: String
    let bundleId: String
    let source: Source
    
    enum CodingKeys: String, CodingKey {
        case name
        case bundleId = "bundle_id"
        case source
    }
}

public struct Source: Codable {
    let path: String
    let info: String
    let config: String
}

