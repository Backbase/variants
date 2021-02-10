//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit

typealias UserInput = () -> String?
struct UserInputSource {
    let doesUserGrantPermissionToOverrideSpec: (UserInput) -> Bool
}

let interactiveShell = UserInputSource { input -> Bool in
    return interactiveShellInput(
        input,
        with: "'variants.yml' spec already exists! Should we override it?",
        suggestion: "[Y]es / [N]o",
        validation: { value -> Bool in
            return ["y", "yes", "n", "no"].contains(value.lowercased())
        }
    )
}

func interactiveShellInput(_ userInput: UserInput, with description: String, suggestion: String, validation: (String) -> Bool) -> Bool  {
    let logger = Logger(verbose: false)
    logger.logInfo("*  ", item: description)
    logger.logInfo(suggestion, item: "")
    guard let input = userInput(), validation(input) else {
        logger.logInfo(item: " ")
        return interactiveShellInput(userInput, with: description, suggestion: suggestion, validation: validation)
    }
    if ["y", "yes"].contains(input.lowercased()) { return true }
    return false
}
