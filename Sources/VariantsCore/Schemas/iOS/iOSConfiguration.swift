//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

// swiftlint:disable type_name

public struct iOSConfiguration: Codable {
    let xcodeproj: String
    let targets: [String: iOSTarget]
    let variants: [iOSVariant]
    private let signing: iOSSigning?
    let custom: [CustomProperty]?
    
    var pbxproj: String {
        return xcodeproj+"/project.pbxproj"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let variants = try container.decode([iOSVariant].self, forKey: .variants)
        let globalSigning = try? container.decode(iOSSigning.self, forKey: .signing)
        
        guard globalSigning != nil || variants.filter({ $0.signing == nil }).isEmpty else {
            throw RuntimeError(
                """
                At least one variant doesn't contain a 'signing' configuration.
                Create a global 'signing' configuration or make sure all variants have this property.
                """)
        }
        
        var definiteVariants: [iOSVariant] = []
        try variants.forEach { variant in
            var signing = globalSigning
            
            if let variantSigning = variant.signing {
                signing = try variantSigning ~ globalSigning
            } else if let nonOptionalSigning = signing {
                signing = try nonOptionalSigning ~ nil
            }
            
            definiteVariants.append(
                iOSVariant(name: variant.name,
                           app_icon: variant.app_icon,
                           id_suffix: variant.id_suffix,
                           version_name: variant.version_name,
                           version_number: variant.version_number,
                           signing: signing,
                           custom: variant.custom,
                           store_destination: variant.store_destination)
            )
        }
        
        self.xcodeproj = try container.decode(String.self, forKey: .xcodeproj)
        self.targets = try container.decode([String: iOSTarget].self, forKey: .targets)
        self.variants = definiteVariants
        self.signing = nil
        self.custom = try? container.decode([CustomProperty].self, forKey: .custom)
    }
}
