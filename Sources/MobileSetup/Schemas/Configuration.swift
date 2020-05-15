//
//  MobileSetup
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
    var name: String { get }
    var targets: [String: Target] { get }
    var variants: [Variant] { get }
}

public struct iOSConfiguration: Codable, BaseConfiguration {
    public var name: String
    public var targets: [String : Target]
    public var variants: [Variant]
}

public struct AndroidConfiguration: Codable, BaseConfiguration {
    public var name: String
    public var targets: [String : Target]
    public var variants: [Variant]
}

public struct Target: Codable {
    let bundleId: String
    let source: Source
}

public struct Source: Codable {
    let path: String
    let info: String
    let config: String
}

