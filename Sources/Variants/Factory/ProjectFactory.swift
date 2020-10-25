//
// Created by Balazs Toth on 25/10/2020.
// Copyright © 2020. All rights reserved.
// 

import Foundation

struct ProjectFactory {
    static func from(platform: Platform) -> Project {
        switch platform {
        case .ios:
            return iOSProject()
        case .android:
            return AndroidProject()
        }
    }
}
