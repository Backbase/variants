//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation

public struct AndroidVariant: Codable {
    let name: String
    let versionName: String
    let versionCode: String
    let idSuffix: String?
    let taskBuild: String
    let taskUnitTest: String
    let taskUitest: String
    let custom: [CustomProperty]?
    internal let store_destination: String?
    
    var configName: String {
        switch name {
        case "default":
            return ""
        default:
            return " "+name
        }
    }
    
    var configIdSuffix: String {
        switch name {
        case "default":
            return ""
        default:
            return idSuffix != nil ? "."+idSuffix! : ""
        }
    }
    
    var destinationProperty: CustomProperty {
        var defaultDestination: Destination = .playStore
        if
            let storeDestination = store_destination,
            let destination = Destination(rawValue: storeDestination.lowercased()) {
            defaultDestination = destination
        }
        return CustomProperty(
            name: "STORE_DESTINATION",
            value: defaultDestination.rawValue,
            destination: .fastlane
        )
    }
}

extension AndroidVariant {
    enum Destination: String, Codable {
        case appCenter = "appcenter"
        case playStore = "playstore"
    }
}

/*
 * Used by `AndroidConfiguration` decode variant from YAML spec
 * as dictionary `[String: UnnamedAndroidVariant]` and expose array `[AndroidVariant]`.
 */
public struct UnnamedAndroidVariant: Codable {
    let versionName: String
    let versionCode: String
    

}
