//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

public struct Variant: Codable {
    let name: String
    let id_suffix: String?
    let version_name: String
    let version_number: Int
    let custom: [String: String]?
    
    func getDefaultValues(for target: Target) -> [String: String] {
        var customDictionary: [String: String] = [
            "V_APP_NAME": target.name+configName,
            "V_BUNDLE_ID": target.bundleId+configIdSuffix,
            "V_VERSION_NAME": version_name,
            "V_VERSION_NUMBER": String(version_number)
        ]
       
        custom?.forEach({ (key, value) in
            customDictionary["\(key.uppercased())"] = value
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
}

public struct Environment: Codable {
    let env: String
    let cxp: CXP
    let identity: Identity
}

public struct CXP: Codable {
    let serverURL: String
    let experience: String?
    let version: String?
    let navigationType: String?
}

public struct Identity: Codable {
    let baseURL: String
    let realm: String?
    let clientId: String?
}
