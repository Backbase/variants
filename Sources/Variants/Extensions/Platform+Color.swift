//
//  File.swift
//  
//
//  Created by Giuseppe Deraco on 16/10/2020.
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
