//
//  StandardOutputStream.swift
//  VariantsCoreTests
//
//  Created by Abdoelrhman Eaita on 17/09/2021.
//

import Foundation

struct StandardOutputStream: TextOutputStream {
    let fileHandler: FileHandle
    func write(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        fileHandler.write(data)
    }
}
