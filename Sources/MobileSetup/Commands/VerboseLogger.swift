//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import SwiftCLI

let VerboseFlag = Flag("-v", "--verbose", description: "Log tech details for nerds")

enum ShellColor: String {
    case blue = "\\033[0;34m"
    case red = "\\033[1;31m"
    case green = "\\033[0;32m"
    case cyan = "\\033[0;36m"
    case purple = "\\033[0;35m"
    case neutral = "\\033[0m"
}

protocol VerboseLogger {
    var verbose: Bool { get }
    var stdout: SwiftCLI.WritableStream { get }
    func log(_ item: Any, indentationLevel: Int)
    func log(_ item: Any, color: ShellColor)
}

extension VerboseLogger {
    var verbose: Bool { VerboseFlag.value }

    func log(_ item: Any, indentationLevel: Int = 0) {
        guard verbose else { return }
        let indentation = String(repeating: "   ", count: indentationLevel)
        stdout <<< "\(indentation)→ \(item)"
    }
    
    func log(_ item: Any, color: ShellColor) {
        guard verbose else { return }
        try? Task.run("printf", "\(color.rawValue)\(item)\(ShellColor.neutral.rawValue)")
    }
}
