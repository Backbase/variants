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
    let custom: [String]?
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
