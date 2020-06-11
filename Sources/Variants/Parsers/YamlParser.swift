//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import SwiftCLI
import Yams

public protocol YamlParser: VerboseLogger {
    var verbose: Bool { get }
    func extractConfiguration(from configurationPath: String, platform: Platform?) -> Configuration
}

extension YamlParser {
    public var verbose: Bool { VerboseFlag.value }
    
    public func extractConfiguration(from configurationPath: String, platform: Platform? = .unknown) -> Configuration {
        let decoder = YAMLDecoder()
        let encoder = YAMLEncoder()
        
        do {
            let encodedYAML = try String(contentsOfFile: configurationPath, encoding: .utf8)
            let decoded: Configuration = try decoder.decode(Configuration.self, from: encodedYAML)
            
            Logger.shared.logInfo("Loaded configuration", item: "")
            var encoded = try encoder.encode(decoded)
            
            switch platform {
            case .ios:
                encoded = try encoder.encode(decoded.ios)
            case .android:
                encoded = try encoder.encode(decoded.android)
            default: break
            }
            
            let nsString = encoded as NSString
            nsString.enumerateLines { (stringLine, _) in
                Logger.shared.log(item: stringLine, indentationLevel: 1, color: .purple, logLevel: .verbose)
            }
            
            return decoded
            
        } catch {
            Logger.shared.logError("❌ ", item: error.localizedDescription)
            exit(1)
        }
    }
}
