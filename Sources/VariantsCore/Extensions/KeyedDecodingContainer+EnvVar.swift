//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//

import Foundation
public extension KeyedDecodingContainer {
    func decodeOrReadFromEnv(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> String {
        let decodedValue = try decode(String.self, forKey: key)
        return try decodedValue.asEnvVariable ?? decodedValue
    }
    
    func decodeIfPresentOrReadFromEnv(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> String? {
        guard let decodedValue = try decodeIfPresent(String.self, forKey: key) else{
            return nil
        }
        return try decodedValue.asEnvVariable ?? decodedValue
    }
    
    func decodeOrReadFromEnv(_ type: Int.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Int {
        if let valueFromEnv = try? Int(decodeOrReadFromEnv(String.self, forKey: key)) {
            return valueFromEnv
        } else {
            return try decode(Int.self, forKey: key)
        }
    }
}

fileprivate extension String {
    var asEnvVariable: String? {
        get throws {
            let regexPattern = #"^\$\{\{ envVars.(?<name>.*) \}\}"#
            
            let regex = try? NSRegularExpression(
                pattern: regexPattern
            )
            
            guard
                let regexMatch = regex?.firstMatch(in: self, range: NSRange(location: 0, length: self.count)),
                let envVarNameRange = Range(regexMatch.range(withName: "name"), in: self)
            else { return nil }
            
            let envVarName = String(self[envVarNameRange])

            guard
                let envVarValue = getenv(envVarName)
            else {
                throw EnvVarNotSetError.runtimeError("Couldn't find any value set to the environmental variable \(envVarName)")
            }
            return String(utf8String: envVarValue)
        }
    }
}
