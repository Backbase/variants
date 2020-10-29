//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import Yams

class YamlParser {
    public func extractConfiguration(from configurationPath: String, platform: Platform?) throws -> Configuration {
        let decoder = YAMLDecoder()
        let encoder = YAMLEncoder()
        
        let encodedYAML = try String(contentsOfFile: configurationPath, encoding: .utf8)
        let decoded: Configuration = try decoder.decode(Configuration.self, from: encodedYAML)
        
        Logger.shared.logInfo("Loading configuration", item: "")
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
    }
}
