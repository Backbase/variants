//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation

extension FileManager {
    func writeTemporaryFile(withContent value: String) throws -> String {
        guard let filePath = try Bash("mktemp").capture() else {
            throw "Could not create the temporary file"
        }
        try value.write(to: URL(fileURLWithPath: filePath), atomically: false, encoding: .utf8)
        return filePath
    }
}
