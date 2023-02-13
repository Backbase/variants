//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//
// swiftlint:disable all

import Foundation
public struct Variants {
    static let configuration: [String: Any] = {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            fatalError("Info.plist file not found")
        }
        return infoDictionary
    }()
    
    // MARK: - ConfigurationValueKey
    /// Custom configuration values coming from variants.yml as enum cases
    public enum ConfigurationValueKey: String {
    
        case OTHER_SWIFT_FLAGS
    }
    static func configurationValue(for key: ConfigurationValueKey) -> Any? {
        return Self.configuration[key.rawValue]
    }
    
}
