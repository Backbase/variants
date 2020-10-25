//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import ArgumentParser
import PathKit

struct ConfigurationHelper: YamlParser {
    let verbose: Bool
    
    func loadConfiguration(_ path: String?, platform: Platform) throws -> Configuration? {
        guard let path = path else {
            throw ValidationError("Error: Use '-s' to specify the configuration file")
        }
        
        let configurationPath = Path(path)
        guard !configurationPath.isDirectory else {
            throw ValidationError("Error: \(configurationPath) is a directory path")
        }
        
        let configuration = extractConfiguration(from: path, platform: platform)
        return configuration
    }
}
