//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation

extension String {
    mutating func addExportVariable(_ name: String, value: String) {
        self.appendLine("export \(name)=\(value.envVarValue() ?? value)")
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
