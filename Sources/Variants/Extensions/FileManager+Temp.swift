//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation
import SwiftCLI

extension FileManager {
    func writeTemporaryFile(withContent value: String) throws -> String {
        let filePath = try Task.capture(bash: "mktemp").stdout
        try value.write(to: URL(fileURLWithPath: filePath), atomically: false, encoding: .utf8)
        return filePath
        
    }
}
