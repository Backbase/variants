//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

// swiftlint:disable type_name

import Foundation

internal extension CodingUserInfoKey {
    static let bundleID = CodingUserInfoKey(rawValue: "bundle_id")!
}

public struct iOSConfiguration: Codable {
    let xcodeproj: String
    let target: iOSTarget
    let variants: [iOSVariant]
    let custom: [CustomProperty]?
    
    private let postSwitchScript: String?
    private let signing: iOSSigning?
        
    var pbxproj: String {
        return xcodeproj + "/project.pbxproj"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.xcodeproj = try container.decode(String.self, forKey: .xcodeproj)
        self.target = try container.decode(iOSTarget.self, forKey: .target)

        let globalCustomProperties = try? container.decode([CustomProperty].self, forKey: .custom)
        self.custom = globalCustomProperties

        let globalPostSwitchScript = try container.decodeIfPresent(String.self, forKey: .postSwitchScript)
        let globalSigning = try container.decodeIfPresent(iOSSigning.self, forKey: .signing)
        let variantsDict = try container.decode([String: UnnamediOSVariant].self, forKey: .variants)
        
        self.postSwitchScript = globalPostSwitchScript
        self.signing = globalSigning
        self.variants = try variantsDict
            .map { 
                try iOSVariant(from: $1, name: $0, globalCustomProperties: globalCustomProperties,
                    globalSigning: globalSigning, globalPostSwitchScript: globalPostSwitchScript) }
    }
}

// swiftlint:enable type_name
