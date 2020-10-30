//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit

extension String {
    func appendLine(to file: Path) throws {
        try (self + "\n").appendToURL(fileURL: file.url)
    }
    
    mutating func appendLine(_ value: String) {
        self = self + value + "\n"
    }
    
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}
