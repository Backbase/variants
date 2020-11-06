//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import XCTest
import PathKit
@testable import VariantsCore

class CustomPropertyEnvironmentVarTests: XCTestCase {
    func testProcessForEnvironment_forProject_true() {
        let environmentVarProperty = CustomProperty(
            name: "AN_ENV_VAR",
            value: "{{ envVars.A_SECRET }}",
            destination: .project
        )
        
        XCTAssertTrue(
            environmentVarProperty.processForEnvironment().isEnvVar,
            "After processing `isEnvVar` should be true as it matches the pattern"
        )
        
        XCTAssertEqual(
            environmentVarProperty.processForEnvironment().string,
            "A_SECRET",
            "After processing `string` should be processed to extract env var name"
        )
    }
    
    func testProcessForEnvironment_forProject_false() {
        let environmentVarProperty = CustomProperty(
            name: "A_PROPERTY",
            value: "A_VALUE",
            destination: .project
        )
        
        XCTAssertFalse(
            environmentVarProperty.processForEnvironment().isEnvVar,
            "After processing `isEnvVar` should be false as it ddoesn't match the pattern"
        )
        
        XCTAssertEqual(
            environmentVarProperty.processForEnvironment().string,
            environmentVarProperty.value,
            "After processing `string` should be exactly the same"
        )
    }
    
    func testProcessForEnvironment_forFastlane_true() {
        let environmentVarProperty = CustomProperty(
            name: "AN_ENV_VAR",
            value: "{{ envVars.A_SECRET }}",
            destination: .fastlane
        )
        
        XCTAssertTrue(
            environmentVarProperty.processForEnvironment().isEnvVar,
            "After processing `isEnvVar` should be true as it matches the pattern"
        )
        
        XCTAssertEqual(
            environmentVarProperty.processForEnvironment().string,
            "ENV[\"A_SECRET\"]",
            "After processing `string` should be processed to extract env var name"
        )
    }
    
    func testProcessForEnvironment_forFastlane_false() {
        let environmentVarProperty = CustomProperty(
            name: "A_PROPERTY",
            value: "A_VALUE",
            destination: .fastlane
        )
        
        XCTAssertFalse(
            environmentVarProperty.processForEnvironment().isEnvVar,
            "After processing `isEnvVar` should be false as it ddoesn't match the pattern"
        )
        
        XCTAssertEqual(
            environmentVarProperty.processForEnvironment().string,
            environmentVarProperty.value,
            "After processing `string` should be exactly the same"
        )
    }
    
    static var allTests = [
        ("testProcessForEnvironment_forProject_true", testProcessForEnvironment_forProject_true),
        ("testProcessForEnvironment_forProject_false", testProcessForEnvironment_forProject_false),
        ("testProcessForEnvironment_forFastlane_true", testProcessForEnvironment_forFastlane_true),
        ("testProcessForEnvironment_forFastlane_false", testProcessForEnvironment_forFastlane_false)
    ]
}
