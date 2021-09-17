//
//  StandardOutputStream.swift
//  VariantsCoreTests
//
//  Created by Abdoelrhman Eaita on 17/09/2021.
//

import Foundation

struct StandardOutputStream: TextOutputStream {
    let stdoud = FileHandle.standardOutput

    func write(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        stdoud.write(data)
    }
}

struct StandardErrorOutputStream: TextOutputStream {
    let stderr = FileHandle.standardError

    func write(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        stderr.write(data)
    }
}
