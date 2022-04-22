//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//

import Foundation
extension String {
    func extractEnvVarIfAny() -> String {
        let regexPattern = #"^\$\{\{ envVars.(?<name>.*) \}\}"#

        let regex = try? NSRegularExpression(
            pattern: regexPattern
        )

        if let match = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf8.count)) {
                if let envVarNameIndex = Range(match.range(withName: "name"), in: self) {
                    guard let envVarRawValue = getenv(String(self[envVarNameIndex])) else { return "" }
                        return String(utf8String: envVarRawValue) ?? ""
                } else {
                    return self
                }
        }
        return self
    }
}
