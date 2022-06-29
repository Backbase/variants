//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Abdoelrhman Eaita on 01/10/2021.
//

import Foundation

public struct LogData {
    var prefix: Any = ""
    let item: Any
    var indentationLevel = 0
    var color: ShellColor = .neutral
    var logLevel: LogLevel = .none
    var date = Date()
    
    public init(_ prefix: Any = "", item: Any, indentationLevel: Int = 0, color: ShellColor = .neutral, logLevel: LogLevel = .none) {
        self.prefix = prefix
        self.item = item
        self.indentationLevel = indentationLevel
        self.color = color
        self.logLevel = logLevel
    }
    
    // testing initializer
    init(item: Any, indentationLevel: Int, color: ShellColor, logLevel: LogLevel, date: Date = Date()) {
        self.init("", item: item, indentationLevel: indentationLevel, color: color, logLevel: logLevel)
        self.date = date
    }
}
