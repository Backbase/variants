//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

// swiftlint:disable type_name

public struct iOSConfiguration: Codable {
    public var xcodeproj: String
    public var targets: [String: iOSTarget]
    public var variants: [iOSVariant]
    
    var pbxproj: String {
        return xcodeproj+"/project.pbxproj"
    }
}
