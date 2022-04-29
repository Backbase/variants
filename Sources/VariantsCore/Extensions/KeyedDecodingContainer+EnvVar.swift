//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//

import Foundation
public extension KeyedDecodingContainer {
    func decodeOrReadFromEnv(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> String {
        let decodedValue = try decode(String.self, forKey: key)
        return decodedValue.asEnvVariable ?? decodedValue
    }
    
    func decodeIfPresentOrReadFromEnv(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> String? {
        guard let decodedValue = try decodeIfPresent(String.self, forKey: key) else{
            return nil
        }
        return decodedValue.asEnvVariable ?? decodedValue
    }
    
    func decodeOrReadFromEnv(_ type: Int.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Int {
        var decoded = 0
        do {
            decoded = try Int(decodeOrReadFromEnv(String.self, forKey: key)) ?? 0
        } catch {
            decoded = try decodeIfPresent(Int.self, forKey: key) ?? 0
        }
        return decoded
    }
}

fileprivate extension String {
    var asEnvVariable: String? {
        let regexPattern = #"^\$\{\{ envVars.(?<name>.*) \}\}"#
        
        let regex = try? NSRegularExpression(
            pattern: regexPattern
        )
        
        guard
            let regexMatch = regex?.firstMatch(in: self, range: NSRange(location: 0, length: self.count)),
            let envVarName = Range(regexMatch.range(withName: "name"), in: self),
            let envVarRawValue = getenv(String(self[envVarName]))
        else { return nil }
        return String(utf8String: envVarRawValue)
    }
}
