//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Balazs Toth
//

import Foundation
import PathKit

struct ProjectFactory {
    static func from(platform: Platform) -> Project {
        switch platform {
        case .ios:
            return iOSProject(
                specHelper: iOSSpecHelper(
                    templatePath: Path("/ios/variants-template.yml"),
                    userInput: interactiveShell
                )
            )
        case .android:
            return AndroidProject(
                specHelper: AndroidSpecHelper(
                    templatePath: Path("/android/variants-template.yml"),
                    userInput: interactiveShell
                )
            )
        }
    }
}

let interactiveShell = UserInput { () -> Bool in
    return interactiveShellInput(
        with: "'variants.yml' spec already exists! Should we override it?",
        suggestion: "[Y]es / [N]o") { input -> Bool in
        return ["y", "yes", "n", "no"].contains(input.lowercased())
    }
}

func interactiveShellInput(with description: String, suggestion: String, validation: (String) -> Bool) -> Bool  {
    let logger = Logger(verbose: false)
    logger.logInfo("*  ", item: description)
    logger.logInfo(suggestion, item: "")
    guard let input = readLine(), validation(input) else {
        logger.logInfo(item: " ")
        return interactiveShellInput(with: description, suggestion: suggestion, validation: validation)
    }
    if ["y", "yes"].contains(input.lowercased()) { return true }
    return false
}
