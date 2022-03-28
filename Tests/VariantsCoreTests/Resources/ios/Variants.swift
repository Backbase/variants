//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//
import Foundation
public struct Variants {
    static let configuration: [String: Any] = {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            fatalError("Info.plist file not found")
        }
        return infoDictionary
    }()
}
