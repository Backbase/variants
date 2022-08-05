//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Balazs Toth
//

import Foundation
import PathKit

struct TemplateDirectory {
    var path: Path

    // MARK: - Init methods

    init(
        directories: [String] = [
            "/usr/local/lib/variants/templates",
            "./Templates"
        ]
    ) throws {
        
        var templateDirectories = directories.map(Path.init(stringLiteral:))
        
        if let variantsInstallationPath = try? Bash(
            "which",
            arguments: "variants"
        ).capture() {
            templateDirectories.append(
                Path(variantsInstallationPath.replacingOccurrences(
                    of: "/bin/variants",
                    with: "/lib/variants/templates"
                ))
            )
        }
        
        let firstFoundDirectory = templateDirectories.first(where: \.exists)
        guard let path = firstFoundDirectory else {
            let dirs = directories.joined(separator: " or ")
            throw RuntimeError("Templates folder not found in \(dirs)")
        }

        self.path = path
    }
}
