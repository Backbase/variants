//
// Created by Balazs Toth on 25/10/2020.
// Copyright © 2020. All rights reserved.
// 

import Foundation
import PathKit

struct ProjectFactory {
    static func from(platform: Platform) -> Project {
        switch platform {
        case .ios:
            return iOSProject(
                specHelper: iOSSpecHelper(
                    templatePath: Path("/ios/variants-template.yml")
                )
            )
        case .android:
            return AndroidProject(
                specHelper: AndroidSpecHelper(
                    templatePath: Path("/android/variants-template.yml")
                )
            )
        }
    }
}
