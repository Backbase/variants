//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

struct Match: Codable {
    let gitURL: String
    let type: Type
    
    enum CodingKeys: String, CodingKey {
        case gitURL = "url"
        case type
    }
}

extension Match {
    enum `Type`: String, Codable {
        case appstore
        case development
        case adhoc
        case enterprise
    }
}
