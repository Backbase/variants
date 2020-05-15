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
    func extractConfiguration(from configurationPath: String, platform: Platform?) throws -> Configuration
}

extension YamlParser {
    public var verbose: Bool { VerboseFlag.value }
    
    public func extractConfiguration(from configurationPath: String, platform: Platform? = .unknown) throws -> Configuration {
        let decoder = YAMLDecoder()
        let encoder = YAMLEncoder()
        
        do {
            let encodedYAML = try String(contentsOfFile: configurationPath, encoding: .utf8)
            let decoded: Configuration = try decoder.decode(Configuration.self, from: encodedYAML)
            
            log("Loaded configuration:", force: true)
            
            switch platform {
            case .ios:
                try log("\n\(encoder.encode(decoded.ios))\n", color: .purple, force: true)
                
            case .android:
                try log("\n\(encoder.encode(decoded.android))\n", color: .purple, force: true)
                
            default:
                try log("\n\(encoder.encode(decoded))\n", color: .purple, force: true)
            }
            
            return decoded
            
        } catch {
            log("Error reading configuration file \(configurationPath)")
            throw CLI.Error(message: error.localizedDescription)
        }
    }
}
