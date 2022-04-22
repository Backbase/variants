//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//

import Foundation
extension KeyedDecodingContainer {
    public func decode(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key, extractEnvVar: Bool) throws -> String {
        let decodedValue = try self.decode(String.self, forKey: key).extractEnvVarIfAny()
        if extractEnvVar {
            return decodedValue.extractEnvVarIfAny()
        } else {
            return decodedValue
        }
    }
    
    public func decode(_ type: Int.Type, forKey key: KeyedDecodingContainer<K>.Key, extractEnvVar: Bool) throws -> Int {
        let decodedValue = try self.decode(Int.self, forKey: key)
        if extractEnvVar {
            return Int(String(decodedValue).extractEnvVarIfAny()) ?? 0
        } else {
            return decodedValue
        }
    }
}
