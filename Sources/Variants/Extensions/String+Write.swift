//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit

extension String {
    func appendLine(to file: Path) throws {
        try (self + "\n").appendToURL(fileURL: file.url)
    }
    
    mutating func appendLine(_ value: String) {
        self = self + value + "\n"
    }
    
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
    
    func envVarValue() -> String?
    {        
        let regexPattern = #"^\{\{ envVars.(?<name>.*) \}\}"#
        
        let regex = try? NSRegularExpression(
            pattern: regexPattern
        )
        
        if let match = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf8.count)) {
            if #available(OSX 10.13, *) {
                if let envVarName = Range(match.range(withName: "name"), in: self) {
                    guard let envVarValue = ProcessInfo.processInfo.environment[String(self[envVarName])] else {
                        return nil
                    }
                    return envVarValue
                } else {
                    return nil
                }
            }
        }
        return nil
    }
}
