//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

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
