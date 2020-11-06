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
    let custom: [CustomProperty]?
    
    var pbxproj: String {
        return xcodeproj+"/project.pbxproj"
    }
}
