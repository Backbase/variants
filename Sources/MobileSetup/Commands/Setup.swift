//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import SwiftCLI
import Yams

protocol Setup: YamlParser {
    var configurationData: Configuration? { get set }
    func decode(configuration: String) -> Configuration?
}

extension Setup {
    func decode(configuration: String) -> Configuration? {
        do {
            return try extractConfiguration(from: configuration)
        } catch {
            log(error.localizedDescription)
        }
        return nil
    }
}
