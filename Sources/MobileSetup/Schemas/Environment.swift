//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

public struct Environment: Codable, Classable {
    static let _class = "environment"
    
    let env: String
    let cxp: String
    let identity: String
}
