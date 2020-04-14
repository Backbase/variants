//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import SwiftCLI
import Yams

protocol YamlParser: VerboseLogger {
    var verbose: Bool { get }
    func extractConfiguration(from configurationPath: String) throws -> Configuration
}

extension YamlParser {
    var verbose: Bool { VerboseFlag.value }
    
    func extractConfiguration(from configurationPath: String) throws -> Configuration {
        let decoder = YAMLDecoder()
        
        do {
            let encodedYAML = try String(contentsOfFile: configurationPath, encoding: .utf8)
            log("\nLoaded configuration:")
            log("\n\(encodedYAML)\n", color: .purple)
            
            let decoded: Configuration = try decoder.decode(Configuration.self, from: encodedYAML)
            return decoded
            
        } catch {
            log("Error reading configuration file \(configurationPath)")
            throw CLI.Error(message: error.localizedDescription)
        }
    }
}
