//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation

extension Platform {
    var color: ShellColor {
        switch(self) {
        case .ios:
            return .ios
        case .android:
            return .android
        case .unknown:
            return .neutral
        }
    }
}
