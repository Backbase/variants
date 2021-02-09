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
                    userInputHelper: UserInputHelper()
                )
            )
        case .android:
            return AndroidProject(
                specHelper: AndroidSpecHelper(
                    templatePath: Path("/android/variants-template.yml"),
                    userInputHelper: UserInputHelper()
                )
            )
        }
    }
}
