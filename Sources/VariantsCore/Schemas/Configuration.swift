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

public struct CustomProperty: Codable {
    public var name: String
    public var value: String
    public var destination: Destination
    
    public enum Destination: String, Codable {
        case project = "project"
        case fastlane = "fastlane"
        case envVar = "environment"
    }
}

extension CustomProperty: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
}
