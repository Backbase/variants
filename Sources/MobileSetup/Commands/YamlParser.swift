//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import SwiftCLI
import Yams

public protocol YamlParser: VerboseLogger {
    var verbose: Bool { get }
    func extractConfiguration(from configurationPath: String) throws -> Configuration
}

extension YamlParser {
    public var verbose: Bool { VerboseFlag.value }
    
    public func extractConfiguration(from configurationPath: String) throws -> Configuration {
        let decoder = YAMLDecoder()
        let encoder = YAMLEncoder()
        
        do {
            let encodedYAML = try String(contentsOfFile: configurationPath, encoding: .utf8)
            let decoded: Configuration = try decoder.decode(Configuration.self, from: encodedYAML)
            
            log("Loaded configuration:", force: true)
            try log("\n\(encoder.encode(decoded))\n", color: .purple, force: true)
            
            return decoded
            
        } catch {
            log("Error reading configuration file \(configurationPath)")
            throw CLI.Error(message: error.localizedDescription)
        }
    }
}
