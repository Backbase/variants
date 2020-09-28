//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import SwiftCLI

public class Logger: VerboseLogger {
    static let shared = Logger()
    
    func logFatal(_ prefix: Any = "❌ ", item: Any, color: ShellColor = .red) {
        logError(prefix, item: item, color: color)
        exit(1)
    }
    
    func logError(_ prefix: Any = "", item: Any, color: ShellColor = .red) {
        divider(logLevel: .error)
        log(prefix, item: item, color: color, logLevel: .error)
        divider(logLevel: .error)
    }
    
    func logInfo(_ prefix: Any = "", item: Any, indentationLevel: Int = 0, color: ShellColor = .neutral) {
        log(prefix, item: item, indentationLevel: indentationLevel, color: color, logLevel: .info)
    }
    
    func logDebug(_ prefix: Any = "", item: Any, indentationLevel: Int = 0, color: ShellColor = .neutral) {
        log(prefix, item: item, indentationLevel: indentationLevel, color: color, logLevel: .verbose)
    }
    
    func logSection(_ prefix: Any = "", item: Any, color: ShellColor = .neutral) {
        divider(logLevel: .info)
        log(prefix, item: item, color: color, logLevel: .info)
        divider(logLevel: .info)
    }
    
    // MARK: - Private
    
    private func divider(logLevel: LogLevel) {
        log(item: "--------------------------------------------------------------------------------------", logLevel: logLevel)
    }
}
