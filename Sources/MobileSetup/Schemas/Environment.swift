//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

public struct Variant: Codable {
    let name: String
    let id_suffix: String
    let version_name: String
    let version_number: Int
    let custom: [String: String]?
    
    func getDefaultValues(for target: Target) -> [String: String] {
        var customDictionary: [String: String] = [
            "MV_APP_NAME": target.name+" "+name,
            "MV_BUNDLE_ID": target.bundleId+"."+id_suffix,
            "MV_VERSION_NAME": version_name,
            "MV_VERSION_NUMBER": String(version_number)
        ]
       
        custom?.forEach({ (key, value) in
            customDictionary["MV_\(key.uppercased())"] = value
        })
        
        return customDictionary
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
