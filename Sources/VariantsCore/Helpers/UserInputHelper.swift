//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit

public class UserInputHelper {
    public init(
        logger: Logger = Logger.shared
    ) {
        self.logger = logger
    }
    
    /// Asks the user (through interactive shell) if the Variants spec should be overriden.
    /// - Returns: Bool
    public func doesUserGrantPermissionToOverrideSpec() -> Bool {
        let shouldOverrideSpec = Bool(userInput(
            with: "'variants.yml' spec already exists! Should we override it?",
            suggestion: "[Y]es / [N]o") { input -> Bool in
            return ["y", "yes", "n", "no"].contains(input.lowercased())
        }) ?? false
        
        return shouldOverrideSpec
    }
    
    private func userInput(with description: String, suggestion: String, validation: (String) -> Bool) -> String  {
        logger.logInfo("*  ", item: description)
        logger.logInfo(suggestion, item: "")
        guard let input = readLine(), validation(input) else {
            logger.logInfo(item: " ")
            return userInput(with: description, suggestion: suggestion, validation: validation)
        }
        logger.logInfo(item: " ")
        if ["y", "yes"].contains(input.lowercased()) {
            return "true"
        } else if ["n", "no"].contains(input.lowercased()) {
            return "false"
        }
        return input
    }
    
    private let logger: Logger
}
