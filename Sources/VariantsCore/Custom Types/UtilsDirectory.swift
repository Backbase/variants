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
            "~/.local/lib/variants/utils",
            "./utils"
        ]
    ) throws {
        var utilsDirectories = directories.map { Path($0).absolute() }
        
        if let variantsInstallationPath = try? Bash(
            "which",
            arguments: "variants"
        ).capture() {
            utilsDirectories.append(
                Path(variantsInstallationPath.replacingOccurrences(
                    of: "/bin/variants",
                    with: "/lib/variants/utils"
                ))
            )
        }
        
        let firstFoundDirectory = utilsDirectories.first(where: \.exists)
        guard let path = firstFoundDirectory else {
            let dirs = directories.joined(separator: " or ")
            throw RuntimeError("Utils folder not found in \(dirs)")
        }

        self.path = path
    }
}
