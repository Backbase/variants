//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

// swiftlint:disable type_name

public struct iOSVariant: Variant {
    let name: String
    let app_icon: String?
    let id_suffix: String?
    let version_name: String
    let version_number: Int
    let signing: iOSSigning?
    let custom: [CustomProperty]?
    internal let store_destination: String?
    
    public var title: String { return name }
    
    func getDefaultValues(for target: iOSTarget) -> [String: String] {
        let bundleId = target.bundleId+configIdSuffix
        
        var customDictionary: [String: String] = [
            "V_APP_NAME": target.name+configName,
            "V_BUNDLE_ID": bundleId,
            "V_VERSION_NAME": version_name,
            "V_VERSION_NUMBER": String(version_number),
            "V_APP_ICON": app_icon ?? target.app_icon
        ]
       
        if
            signing?.matchURL != nil,
            let exportMethod = signing?.exportMethod {
            customDictionary["V_MATCH_PROFILE"] = exportMethod.prefix+" "+bundleId
        }
        
        custom?
            .filter { $0.destination == .project && !$0.isEnvironmentVariable }
            .forEach({ config in
                customDictionary[config.name] = config.value
            })
        
        return customDictionary
    }
    
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
            return id_suffix != nil ? "."+id_suffix! : ""
        }
    }
    
    var destinationProperty: CustomProperty {
        var defaultDestination: Destination = .appStore
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

extension iOSVariant {
    enum Destination: String, Codable {
        case appCenter = "appcenter"
        case appStore = "appstore"
        case testFlight = "testflight"
    }
}

/*
 * Used by `iOSConfiguration` decode variant from YAML spec
 * as dictionary `[String: UnnamediOSVariant]` and expose array `[iOSVariant]`.
 */
struct UnnamediOSVariant: Codable {
    let app_icon: String?
    let id_suffix: String?
    let version_name: String
    let version_number: Int
    let signing: iOSSigning?
    let custom: [CustomProperty]?
    internal let store_destination: String?
}
