//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

struct iOSSigning: Codable {
    let teamName: String?
    let teamID: String?
    let exportMethod: Type?
    let matchURL: String?
    
    enum CodingKeys: String, CodingKey {
        case teamName = "team_name"
        case teamID = "team_id"
        case exportMethod = "export_method"
        case matchURL = "match_url"
    }
}

extension iOSSigning {
    enum `Type`: String, Codable {
        case appstore
        case development
        case adhoc
        case enterprise
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

infix operator ~: AdditionPrecedence
extension iOSSigning {
    static func ~ (lhs: iOSSigning, rhs: iOSSigning?) throws -> iOSSigning {
        let signing = iOSSigning(teamName: lhs.teamName ?? rhs?.teamName,
                                 teamID: lhs.teamID ?? rhs?.teamID,
                                 exportMethod: lhs.exportMethod ?? rhs?.exportMethod,
                                 matchURL: lhs.matchURL ?? rhs?.matchURL)
        if signing.teamName == nil {
            throw iOSSigning.missingParameterError(CodingKeys.teamName)
        } else if signing.teamID == nil {
            throw iOSSigning.missingParameterError(CodingKeys.teamID)
        } else if signing.exportMethod == nil {
            throw iOSSigning.missingParameterError(CodingKeys.exportMethod)
        }
        return signing
    }
}
