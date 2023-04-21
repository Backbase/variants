//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

// swiftlint:disable type_name

internal extension CodingUserInfoKey {
    static let bundleID = CodingUserInfoKey(rawValue: "bundle_id")!
}

public struct iOSConfiguration: Codable {
    let xcodeproj: String
    let targets: [String: iOSTarget]
    let variants: [iOSVariant]
    let custom: [CustomProperty]?
    private let signing: iOSSigning?
        
    var pbxproj: String {
        return xcodeproj+"/project.pbxproj"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.xcodeproj = try container.decode(String.self, forKey: .xcodeproj)
        self.targets = try container.decode([String: iOSTarget].self, forKey: .targets)
        self.custom = try? container.decode([CustomProperty].self, forKey: .custom)
        
        let globalSigning = try container.decodeIfPresent(iOSSigning.self, forKey: .signing)
        let variantsDict = try container.decode([String: UnnamediOSVariant].self, forKey: .variants)
        
        self.signing = globalSigning
        self.variants = try variantsDict
            .map { try iOSVariant(from: $1, name: $0, globalSigning: globalSigning) }
    }
}

// swiftlint:enable type_name
