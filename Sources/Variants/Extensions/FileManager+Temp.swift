//
//  File.swift
//  
//
//  Created by Giuseppe Deraco on 28/09/2020.
//
import Foundation
import SwiftCLI

extension FileManager {
    func writeTemporaryFile(withContent value: String) throws -> String {
        let filePath = try Task.capture(bash: "mktemp").stdout
        try value.write(to: URL(fileURLWithPath: filePath), atomically: false, encoding: .utf8)
        return filePath
        
    }
}
