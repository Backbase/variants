//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import ArgumentParser

internal extension CodingUserInfoKey {
    static let bundleID = CodingUserInfoKey(rawValue: "bundle_id")!
}

// swiftlint:disable:next type_name
public struct iOSConfiguration: Codable {
    let xcodeproj: String
    let target: iOSTarget
    let extensions: [iOSExtension]
    let variants: [iOSVariant]
    let custom: [CustomProperty]?
    
    private let postSwitchScript: String?
    private let signing: iOSSigning?
        
    var pbxproj: String {
        return xcodeproj + "/project.pbxproj"
    }

    var defaultVariant: iOSVariant {
        get throws {
            guard  let defaultVariant = variants.first(where: { $0.name.lowercased() == "default" })
            else { throw ValidationError("Variant 'default' not found.") }
            return defaultVariant
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.xcodeproj = try container.decode(String.self, forKey: .xcodeproj)
        self.target = try container.decode(iOSTarget.self, forKey: .target)
        self.extensions = try container.decodeIfPresent([iOSExtension].self, forKey: .extensions) ?? []

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
