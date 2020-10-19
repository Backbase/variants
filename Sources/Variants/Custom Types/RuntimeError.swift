//
// Copyright © 2020 Backbase R&D B.V. All rights reserved.
//

import Foundation

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
