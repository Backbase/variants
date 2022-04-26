//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

// swiftlint:disable type_name

public struct iOSVariant: Codable {
    let name: String
    let app_icon: String?
    let id_suffix: String?
    let version_name: String
    let version_number: Int
    let signing: iOSSigning?
    let custom: [CustomProperty]?
    internal let store_destination: String?
    
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
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        app_icon = try values.decodeIfPresent(String.self, forKey: .app_icon, extractEnvVar: true)
        id_suffix = try values.decodeIfPresent(String.self, forKey: .id_suffix, extractEnvVar: true)
        version_name = try values.decode(String.self, forKey: .version_name, extractEnvVar: true)
        version_number = try values.decode(Int.self, forKey: .version_number, extractEnvVar: true)
        signing = try values.decodeIfPresent(iOSSigning.self, forKey: .signing)
        custom = try values.decodeIfPresent([CustomProperty].self, forKey: .custom)
        store_destination = try values.decodeIfPresent(String.self, forKey: .store_destination, extractEnvVar: true)
    }
}
