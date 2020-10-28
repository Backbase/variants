//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit

struct TemplatesManager {
    
    /// Attempt to return the first found template directory.
    /// If nothing is found the return will be nil.
    /// - Returns: Optional Path to an existing template directory.
    func firstFoundTemplateDirectory() -> Path? {
        templateDirectories
            .map(Path.init(stringLiteral:))
            .first(where: \.exists)
    }
    
    var templateDirectories: [String] = [
        "/usr/local/lib/variants/Templates",
        "./Templates"
    ]
}
