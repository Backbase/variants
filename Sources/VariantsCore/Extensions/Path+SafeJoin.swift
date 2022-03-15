//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import PathKit
import Foundation

extension Path {
  func safeJoin(path: Path) throws -> Path {
    let newPath = self + path

    let absoluteNewPath = newPath.absolute().description
    let absoluteCurrentPath = absolute().description
    
    if !absoluteNewPath.hasPrefix(absoluteCurrentPath) {
      throw SuspiciousFileOperation(basePath: self, path: newPath)
    }

    return newPath
  }
}

struct SuspiciousFileOperation: LocalizedError {
    let basePath: Path
    let path: Path
    
    var errorDescription: String? {
        "Path `\(path)` is located outside of base path `\(basePath)`"
    }
}
