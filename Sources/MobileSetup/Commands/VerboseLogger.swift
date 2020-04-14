//
//  File.swift
//  
//
//  Created by Arthur Alves on 14/04/2020.
//

import SwiftCLI

let VerboseFlag = Flag("-v", "--verbose", description: "Log tech details for nerds")

protocol VerboseLogger {
    var verbose: Bool { get }
    var stdout: SwiftCLI.WritableStream { get }
    func log(_ item: Any, indentationLevel: Int)
}

extension VerboseLogger {
    var verbose: Bool { VerboseFlag.value }

    func log(_ item: Any, indentationLevel: Int = 0) {
        guard verbose else { return }
        let indentation = String(repeating: "   ", count: indentationLevel)
        stdout <<< "\(indentation)→ \(item)"
    }
}
