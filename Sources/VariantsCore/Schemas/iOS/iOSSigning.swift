//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

// swiftlint:disable:next type_name
struct iOSSigning: Codable, Equatable {
    let teamName: String?
    let teamID: String?
    let exportMethod: ExportMethod?
    let matchURL: String?
    let style: SigningStyle

    enum CodingKeys: String, CodingKey {
        case teamName = "team_name"
        case teamID = "team_id"
        case exportMethod = "export_method"
        case matchURL = "match_url"
        case style
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.teamName = try container.decodeIfPresent(String.self, forKey: .teamName)
        self.teamID = try container.decodeIfPresent(String.self, forKey: .teamID)
        self.exportMethod = try container.decodeIfPresent(ExportMethod.self, forKey: .exportMethod)
        self.matchURL = try container.decodeIfPresent(String.self, forKey: .matchURL)
        self.style = try container.decodeIfPresent(iOSSigning.SigningStyle.self, forKey: .style) ?? .manual
    }

    init(teamName: String?, teamID: String?, exportMethod: ExportMethod?, matchURL: String?, style: SigningStyle) {
        self.teamName = teamName
        self.teamID = teamID
        self.exportMethod = exportMethod
        self.matchURL = matchURL
        self.style = style
    }
}

extension iOSSigning {
    enum ExportMethod: String, Codable {
        case appstore
        case development
        case adhoc
        case enterprise
        
        var prefix: String {
            switch self {
            case .development:
                return "match Development"
            case .adhoc:
                return "match AdHoc"
            case .appstore:
                return "match AppStore"
            case .enterprise:
                return "match InHouse"
            }
        }
    }

    enum SigningStyle: String, Codable {
        case automatic
        case manual
    }
}

extension iOSSigning {
    static func missingParameterError(_ parameter: CodingKeys) -> RuntimeError {
        return RuntimeError(
            """
            Missing: 'signing.\(parameter.stringValue)'
            At least one variant doesn't contain 'signing.\(parameter.stringValue)' in its configuration.
            Create a global 'signing' configuration with '\(parameter.stringValue)' or make sure all variants have this property.
            """)
    }
}

extension iOSSigning {
    func customProperties() -> [CustomProperty] {
        var customProperties: [CustomProperty] = []
        let mirroredObject = Mirror(reflecting: self)
        for property in mirroredObject.children {
            if let label = property.label {
                let stringValue = property.value as? String
                let typeValue = (property.value as? ExportMethod)?.rawValue
                if let value = stringValue ?? typeValue {
                    customProperties.append(CustomProperty(name: label.uppercased(),
                                                           value: value,
                                                           destination: .fastlane))
                }
            }
        }
        return customProperties
    }
}

infix operator ~: AdditionPrecedence
extension iOSSigning {
    static func ~ (lhs: iOSSigning, rhs: iOSSigning?) throws -> iOSSigning {
        let signing = iOSSigning(
            teamName: lhs.teamName ?? rhs?.teamName,
            teamID: lhs.teamID ?? rhs?.teamID,
            exportMethod: lhs.exportMethod ?? rhs?.exportMethod,
            matchURL: lhs.matchURL ?? rhs?.matchURL,
            style: lhs.style)

        guard signing.teamName != nil else { throw iOSSigning.missingParameterError(CodingKeys.teamName) }
        guard signing.teamID != nil else { throw iOSSigning.missingParameterError(CodingKeys.teamID) }
        guard signing.exportMethod != nil else { throw iOSSigning.missingParameterError(CodingKeys.exportMethod) }
        
        return signing
    }
}
