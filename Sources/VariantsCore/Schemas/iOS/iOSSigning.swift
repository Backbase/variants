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
    let autoDetectSigningIdentity: Bool
    
    var codeSigningIdentity: String? {
        guard let teamID = teamID else { return nil }
        
        return fetchSigningCertificate()
    }

    enum CodingKeys: String, CodingKey {
        case teamName = "team_name"
        case teamID = "team_id"
        case exportMethod = "export_method"
        case matchURL = "match_url"
        case style
        case autoDetectSigningIdentity = "auto_detect_signing_identity"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.teamName = try container.decodeIfPresent(String.self, forKey: .teamName)
        self.teamID = try container.decodeIfPresent(String.self, forKey: .teamID)
        self.exportMethod = try container.decodeIfPresent(ExportMethod.self, forKey: .exportMethod)
        self.matchURL = try container.decodeIfPresent(String.self, forKey: .matchURL)
        self.style = try container.decodeIfPresent(iOSSigning.SigningStyle.self, forKey: .style) ?? .manual
        let signingIdentity = try container.decodeIfPresent(Bool.self, forKey: .autoDetectSigningIdentity)
        self.autoDetectSigningIdentity = signingIdentity ?? true
    }

    init(teamName: String?, teamID: String?, exportMethod: ExportMethod?, matchURL: String?, style: SigningStyle, autoDetectSigningIdentity: Bool) {
        self.teamName = teamName
        self.teamID = teamID
        self.exportMethod = exportMethod
        self.matchURL = matchURL
        self.style = style
        self.autoDetectSigningIdentity = autoDetectSigningIdentity
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
        
        var isDistribution: Bool {
            self == .appstore || self == .enterprise
        }
        
        var certType: String {
            isDistribution ? "Distribution" : "Development"
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
            style: lhs.style,
            autoDetectSigningIdentity: lhs.autoDetectSigningIdentity)

        guard signing.teamName != nil else { throw iOSSigning.missingParameterError(CodingKeys.teamName) }
        guard signing.teamID != nil else { throw iOSSigning.missingParameterError(CodingKeys.teamID) }
        guard signing.exportMethod != nil else { throw iOSSigning.missingParameterError(CodingKeys.exportMethod) }
        
        return signing
    }
}

extension iOSSigning {
    private func fetchSigningCertificate() -> String? {
        guard let teamID else { return nil }
        
        do {
            let output = try Bash("security", arguments: "find-identity", "-v", "-p", "codesigning")
                .capture()
            
            guard let output else { return nil }
            let lines = output.split(separator: "\n")
            
            let matches = lines.compactMap { line -> String? in
                guard line.contains(teamID) else { return nil }
                
                if let teamName, !line.contains(teamName) { return nil }
                if let certType = exportMethod?.certType.lowercased(),
                    !line.contains(certType) { return nil }
                
                let components = line.split(separator: "\"", maxSplits: 2, omittingEmptySubsequences: false)
                guard components.count > 1 else { return nil }
                
                return String(components[1])
            }
            return matches.first
        } catch {
            return nil
        }
    }
}
