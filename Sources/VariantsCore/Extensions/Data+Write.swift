//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

extension Data {
    func append(fileURL: URL) throws {
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        defer {
            fileHandle.closeFile()
        }
        fileHandle.seekToEndOfFile()
        fileHandle.write(self)
    }
}
