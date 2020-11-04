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
    private let store_destination: String?
    let custom: [CustomConfig]?
    
    func getDefaultValues(for target: iOSTarget) -> [String: String] {
        var customDictionary: [String: String] = [
            "V_APP_NAME": target.name+configName,
            "V_BUNDLE_ID": target.bundleId+configIdSuffix,
            "V_VERSION_NAME": version_name,
            "V_VERSION_NUMBER": String(version_number),
            "V_APP_ICON": app_icon ?? target.app_icon
        ]
       
        custom?.forEach({ config in
            customDictionary[config.key] = config.value
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
    
    var destination: Destination {
        guard
            let storeDestination = store_destination,
            let destination = Destination(rawValue: storeDestination.lowercased())
        else { return .appStore }
        return destination
    }
}

public struct CustomConfig: Codable {
    let key: String
    let value: String
}

extension iOSVariant {
    enum Destination: String, Codable {
        case appCenter = "appcenter"
        case appStore = "appstore"
        case testFlight = "testflight"
    }
}
