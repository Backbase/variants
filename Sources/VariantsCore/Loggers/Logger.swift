//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

public class Logger: VerboseLogger, Codable {
    public static let shared = Logger(verbose: false)
    
    init(verbose: Bool, showTimestamp: Bool = false) {
        self.isVerbose = verbose
        self.shouldShowTimestamp = showTimestamp
    }
    
    public var verbose: Bool { return isVerbose }
    public var showTimestamp: Bool { return shouldShowTimestamp }
    
    func logFatal(_ prefix: Any = "❌ ", item: Any, color: ShellColor = .red) {
        logError(prefix, item: item, color: color)
        exit(1)
    }
    
    func logWarning(_ prefix: Any = "⚠️  ", item: Any, indentationLevel: Int = 0, color: ShellColor = .yellow) {
        log(LogData(prefix, item: item, indentationLevel: indentationLevel, color: color, logLevel: .warning))
    }
    
    func logError(_ prefix: Any = "", item: Any, color: ShellColor = .red) {
        divider(logLevel: .error)
        log(LogData(prefix, item: item, color: color, logLevel: .error))
        divider(logLevel: .error)
    }
    
    func logInfo(_ prefix: Any = "", item: Any, indentationLevel: Int = 0, color: ShellColor = .neutral) {
        log(LogData(prefix, item: item, indentationLevel: indentationLevel, color: color, logLevel: .info))
    }
    
    func logDebug(_ prefix: Any = "", item: Any, indentationLevel: Int = 0, color: ShellColor = .neutral) {
        log(LogData(prefix, item: item, indentationLevel: indentationLevel, color: color, logLevel: .verbose))
    }
    
    func logSection(_ prefix: Any = "", item: Any, color: ShellColor = .neutral) {
        divider(logLevel: .info)
        log(LogData(prefix, item: item, color: color, logLevel: .info))
        divider(logLevel: .info)
    }
    
    // MARK: - Private
    
    private func divider(logLevel: LogLevel) {
        log(LogData(item: "--------------------------------------------------------------------------------------", logLevel: logLevel))
    }
    
    private let isVerbose: Bool
    private let shouldShowTimestamp: Bool
}
