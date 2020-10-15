//
//  File.swift
//  
//
//  Created by Giuseppe Deraco on 15/10/2020.
//

import Foundation

public class Printer {
    static let shared = Printer()
    private var stdoutTextOutputStream = StandardOutputStream()
    
    func print(item: String) {
        Swift.print(item, to: &stdoutTextOutputStream)
    }
}

fileprivate struct StandardOutputStream: TextOutputStream {
    let stdoud = FileHandle.standardOutput

    func write(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        stdoud.write(data)
    }
}
