//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//

import Foundation
import XCTest
import Yams

@testable import VariantsCore

private struct Variant: Codable {
    let name: String
    let version: Int
    let store: String?
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeOrReadFromEnv(String.self, forKey: .name)
        version = try values.decodeOrReadFromEnv(Int.self, forKey: .version)
        store = try values.decodeIfPresentOrReadFromEnv(String.self, forKey: .store)
    }
}

final class KeyedDecodingContainerTests: XCTestCase {
    
    let decoder = YAMLDecoder()
    
    func testDoding() throws {
        
        setenv("V_NAME", "variant", 1)
        var variant = try decoder.decode(Variant.self, from: """
                                           name: ${{ envVars.V_NAME }}
                                           version: 12
                                           store: appstore
                                           """)
        XCTAssertEqual(variant.name, "variant")
        XCTAssertEqual(variant.version, 12)
        XCTAssertEqual(variant.store, "appstore")
        
        setenv("V_VERSION", "13", 1)
        variant = try decoder.decode(Variant.self, from: """
                                           name: ${{ envVars.V_NAME }}
                                           version: ${{ envVars.V_VERSION }}
                                           store: PlayStore
                                           """)
        XCTAssertEqual(variant.version, 13)
        
        // test env var set to a string that should have a number
        setenv("V_VERSION", "abc", 1)
        XCTAssertThrowsError(try decoder.decode(Variant.self, from: """
                                           name: ${{ envVars.V_NAME }}
                                           version: ${{ envVars.V_VERSION }}
                                           store: ${{ envVars.V_NOME }}
                                           """))
        
        let abortTest = "Unit test fail for variable set but not found in the environment"
        
        // test var that declared but not found in the environment
        XCTAssertThrowsError(try decoder.decode(Variant.self, from: """
                                           name: ${{ envVars.V_NAME_TYPO }}
                                           version: 1
                                           store: PlayStore
                                           """))  { error in
            guard case DecodingError.dataCorrupted(let dataCorruptedValue) = error else {
                return XCTFail(abortTest)
            }
            
            guard let envVarError = dataCorruptedValue.underlyingError as? EnvVarNotSetError else {
                return XCTFail(abortTest)
            }
            
            guard case EnvVarNotSetError.runtimeError(let value) = envVarError else {
                return XCTFail(abortTest)
            }
            
            XCTAssertEqual(value, "Couldn't find any value set to the environmental variable V_NAME_TYPO")
            
        }
        
    }
}
