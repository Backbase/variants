//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import Yams

class YamlParser {
    public init (
        decoder: YAMLDecoder = YAMLDecoder(),
        encoder: YAMLEncoder = YAMLEncoder()
    ) {
        self.decoder = decoder
        self.encoder = encoder
    }
    
    public func extractConfiguration(from configurationPath: String, platform: Platform?, logger: Logger? = nil) throws -> Configuration {
        let encodedYAML = try String(contentsOfFile: configurationPath, encoding: .utf8)
        let decoded: Configuration = try decoder.decode(Configuration.self, from: encodedYAML)
        
        logger?.logDebug(item: "Loading configuration \(configurationPath)")
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
            logger?.log(item: stringLine, indentationLevel: 1, color: .purple, logLevel: .verbose)
        }
        
        return decoded
    }
    
    var decoder: YAMLDecoder
    var encoder: YAMLEncoder
}
