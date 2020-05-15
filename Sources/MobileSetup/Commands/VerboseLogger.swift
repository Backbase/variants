//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import SwiftCLI

let VerboseFlag = Flag("-v", "--verbose", description: "Log tech details for nerds")

public enum ShellColor: String {
    case blue = "\\033[0;34m"
    case red = "\\033[1;31m"
    case green = "\\033[0;32m"
    case cyan = "\\033[0;36m"
    case purple = "\\033[1;35m"
    case ios = "\\033[1;49;36m"
    case android = "\\033[1;49;33m"
    case neutral = "\\033[0m"
}

public protocol VerboseLogger {
    var verbose: Bool { get }
    var stdout: SwiftCLI.WritableStream { get }
    func log(_ item: Any, indentationLevel: Int, force: Bool)
    func log(_ item: Any, indentationLevel: Int, color: ShellColor, force: Bool)
}

extension VerboseLogger {
    var verbose: Bool { VerboseFlag.value }

    public func log(_ item: Any, indentationLevel: Int = 0, force: Bool = false) {
        guard verbose || force else { return }
        let indentation = String(repeating: "   ", count: indentationLevel)
        stdout <<< "\(indentation)→ \(item)"
    }
    
    public func log(_ item: Any, indentationLevel: Int = 0, color: ShellColor, force: Bool = false) {
        guard verbose || force else { return }
        let indentation = String(repeating: "   ", count: indentationLevel)
        try? Task.run("printf", "\(indentation)\(color.rawValue)\(item)\(ShellColor.neutral.rawValue)")
    }
}
