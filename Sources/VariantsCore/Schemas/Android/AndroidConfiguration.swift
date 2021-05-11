//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation

public struct AndroidConfiguration: Codable {
    let path: String
    let appName: String
    let appIdentifier: String
    let variants: [AndroidVariant]
    let custom: [CustomProperty]?

    enum CodingKeys: String, CodingKey {
        case path = "path"
        case appName = "app_name"
        case appIdentifier = "app_identifier"
        case variants = "variants"
        case custom = "custom"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let variants = try container.decode([String: UnnamedAndroidVariant].self, forKey: .variants)
        
        var definiteVariants: [AndroidVariant] = []
        variants.forEach({ (name, variant) in
            definiteVariants.append(
                AndroidVariant(name: name,
                               versionName: variant.versionName,
                               versionCode: variant.versionCode,
                               idSuffix: variant.idSuffix,
                               taskBuild: variant.taskBuild,
                               taskUnitTest: variant.taskUnitTest,
                               taskUitest: variant.taskUitest,
                               custom: variant.custom,
                               store_destination: variant.store_destination)
            )
        })
        
        self.path = try container.decode(String.self, forKey: .path)
        self.appName = try container.decode(String.self, forKey: .appName)
        self.appIdentifier = try container.decode(String.self, forKey: .appIdentifier)
        self.variants = definiteVariants
        self.custom = try? container.decode([CustomProperty].self, forKey: .custom)
    }
    
    public init(
        path: String,
        appName: String,
        appIdentifier: String,
        variants: [AndroidVariant],
        custom: [CustomProperty]?
    ) {
        self.path = path
        self.appName = appName
        self.appIdentifier = appIdentifier
        self.variants = variants
        self.custom = custom
    }
}
