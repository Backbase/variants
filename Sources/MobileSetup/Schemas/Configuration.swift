//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

struct Configuration: Codable, Classable {
    static let _class = "config"

    let configFolder: String
    let appName: String
    let baseBundleId: String
    let sourceFolder: String
    let environments: [Environment]
}
