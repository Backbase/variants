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
    var name: String
    var value: String
    private var env: Bool? = false
    private(set) var isEnvironmentVariable: Bool
    var destination: Destination

    enum CodingKeys: String, CodingKey {
        case name
        case value
        case env
        case destination
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        var isEnvVar: Bool?
        if container.contains(.env) {
            isEnvVar = try container.decode(Bool?.self, forKey: .env)
        }
        
        name = try container.decode(String.self, forKey: .name)
        value = try container.decode(String.self, forKey: .value)
        isEnvironmentVariable = isEnvVar ?? false
        destination = try container.decode(Destination.self, forKey: .destination)
    }
    
    public init(
        name: String,
        value: String,
        env: Bool = false,
        destination: Destination
    ) {
        self.name = name
        self.value = value
        self.isEnvironmentVariable = env
        self.destination = destination
    }
    
    public enum Destination: String, Codable {
        case project
        case fastlane
    }
}

extension CustomProperty: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
}

extension CustomProperty {
    var environmentValue: String {
        guard isEnvironmentVariable == true else { return value }
        switch destination {
        case .project:
            return value
        case .fastlane:
            return "ENV[\""+value+"\"]"
        }
    }
}
