//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Oleg Baidalka on 29.04.2022.
//

import Foundation
import PathKit

@testable import VariantsCore

class MockProject: Project {
    static var ios: MockProject {
        let specHelper = iOSSpecHelper(
            logger: Logger.shared,
            templatePath: Path("variants-template.yml"),
            userInputSource: interactiveShell,
            userInput: { "yes" }
        )
        return MockProject(specHelper: specHelper)
    }
    
    static var android: MockProject {
        let specHelper = AndroidSpecHelper(
            logger: Logger.shared,
            templatePath: Path("variants-template.yml"),
            userInputSource: interactiveShell,
            userInput: { "yes" }
        )
        return MockProject(specHelper: specHelper)
    }
        
    override func initialize(verbose: Bool) throws {
        // nothing
    }
    
    // MARK: - Commands
    
    override func setup(spec: String, skipFastlane: Bool, verbose: Bool) throws {
        // nothing
    }
    
    override func `switch`(to variant: String, spec: String, verbose: Bool) throws {
        // nothing
    }

    override func list(spec: String) throws -> [Variant] {
        return []
    }    
}
