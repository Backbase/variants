//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Balazs Toth
//

import Foundation
import PathKit

struct ProjectFactory {
    static func from(platform: Platform, logger: Logger) -> Project {
        switch platform {
        case .ios:
            return iOSProject(
                specHelper: iOSSpecHelper(
                    logger: logger,
                    templatePath: Path("/ios/variants-template.yml"),
                    userInputSource: interactiveShell,
                    userInput: { readLine() }
                )
            )
        case .android:
            return AndroidProject(
                specHelper: AndroidSpecHelper(
                    logger: logger,
                    templatePath: Path("/android/variants-template.yml"),
                    userInputSource: interactiveShell,
                    userInput: { readLine() }
                )
            )
        }
    }
}
