//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation

typealias EnvironmentVariableHandler = (isEnvVar: Bool, string: String)

extension CustomProperty {
    func processForEnvironment() -> EnvironmentVariableHandler {
        let regexPattern = #"^\{\{ envVars.(?<name>.*) \}\}"#

        let regex = try? NSRegularExpression(
            pattern: regexPattern
        )

        if let match = regex?.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.utf8.count)) {
            if #available(OSX 10.13, *) {
                if let envVarNameIndex = Range(match.range(withName: "name"), in: value) {
                    let envVarName = String(value[envVarNameIndex])
                    switch destination {
                    case .project:
                        return (isEnvVar: true, string: envVarName)
                    case .fastlane:
                        return (isEnvVar: true, string: "ENV[\""+envVarName+"\"]")
                    }
                } else {
                    return (isEnvVar: false, string: value)
                }
            }
        }
        return (isEnvVar: false, string: value)
    }
}
