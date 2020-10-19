//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import ArgumentParser

//let VerboseFlag = Flag("-v", "--verbose", description: "Log tech details for nerds")

@Flag() var verbose = false

public enum ShellColor: String {
    case blue = "\u{001B}[0;34m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case cyan = "\u{001B}[0;36m"
    case purple = "\u{001B}[0;35m"
    case yellow = "\u{001B}[0;33m"
    case ios = "\u{001B}[0;49;36m"
    case android = "\u{001B}[0;49;33m"
    case neutral = "\u{001B}[0;0m"
    
    func bold() -> String {
        return self.rawValue.replacingOccurrences(of: "[0", with: "[1")
    }
}

public enum LogLevel: String {
    case info = "INFO  "
    case warning = "WARN  "
    case verbose = "DEBUG "
    case error = "ERROR "
    case none = "     "
}

public protocol VerboseLogger {
    var isVerbose: Bool { get }
    func log(_ prefix: Any, item: Any, indentationLevel: Int, color: ShellColor, logLevel: LogLevel)
}

extension Date {
    func logTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
}

extension VerboseLogger {
    #warning("Temporary, remove")
    public var isVerbose: Bool { return verbose }
    
    public func log(_ prefix: Any = "", item: Any, indentationLevel: Int = 0, color: ShellColor = .neutral, logLevel: LogLevel = .none) {
        if logLevel == .verbose {
            guard isVerbose else { return }
        }
        let indentation = String(repeating: "   ", count: indentationLevel)
        var command = ""
        let arguments =  [
            "\(logLevel.rawValue)",
            "[\(Date().logTimestamp())]: ▸ ",
            "\(indentation)",
            "\(color.bold())\(prefix)",
            "\(color.rawValue)\(item)\(ShellColor.neutral.rawValue)"
        ]
        arguments.forEach { command.append($0) }
        var outputStream = StandardErrorOutputStream()
        Swift.print(command, to: &outputStream)
    }
    
    public func logBack(_ prefix: Any = "", item: Any, indentationLevel: Int = 0) -> String {
        let indentation = String(repeating: "   ", count: indentationLevel)
        var command = ""
        let arguments =  [
            "[\(Date().logTimestamp())]: ▸ ",
            "\(indentation)",
            "\(prefix)",
            "\(item)"
        ]
        arguments.forEach { command.append($0) }
        return command
    }
}

fileprivate struct StandardErrorOutputStream: TextOutputStream {
    let stderr = FileHandle.standardError

    func write(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        stderr.write(data)
    }
}
