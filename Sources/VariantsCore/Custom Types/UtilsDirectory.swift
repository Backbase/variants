//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit

struct UtilsDirectory {
    let path: Path

    // MARK: - Init methods

    init(
        directories: [String] = [
            "/usr/local/lib/variants/utils",
            "./utils"
        ]
    ) throws {
        let firstDirectory = directories
            .map(Path.init(stringLiteral:))
            .first(where: \.exists)

        guard let path = firstDirectory else {
            let dirs = directories.joined(separator: " or ")
            throw RuntimeError("Utils folder not found in \(dirs)")
        }

        self.path = path
    }
}
