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
        let firstDirectory = directories
            .map(Path.init(stringLiteral:))
            .first(where: \.exists)

        guard let path = firstDirectory else {
            let dirs = directories.joined(separator: " or ")
            throw RuntimeError("Templates folder not found in \(dirs)")
        }

        self.path = path
    }
}
