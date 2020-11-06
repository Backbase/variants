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
            "System.getenv('A_SECRET')",
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
    
    func testProcessForEnvironment_forFastlane_array() {
        let propertiesArray = [
            CustomProperty(
                name: "A_PROPERTY",
                value: "A_VALUE",
                destination: .fastlane
            ),
            CustomProperty(
                name: "AN_ENV_VAR",
                value: "{{ envVars.A_SECRET }}",
                destination: .fastlane
            )
        ]
        
        let fastlaneParameters = propertiesArray
            .filter { $0.destination == .fastlane }
            .map { (property) -> CustomProperty in
                let processed = property.processForEnvironment()
                if processed.isEnvVar {
                    return CustomProperty(name: property.name,
                                          value: processed.string,
                                          destination: property.destination)
                }
                return property
        }
        
        XCTAssertEqual(fastlaneParameters.count, 2)
        
        XCTAssertEqual(fastlaneParameters.first?.name, "A_PROPERTY")
        XCTAssertEqual(fastlaneParameters.first?.value, "A_VALUE")
        
        XCTAssertEqual(fastlaneParameters.last?.name, "AN_ENV_VAR")
        XCTAssertEqual(fastlaneParameters.last?.value, "ENV[\"A_SECRET\"]")
    }
    
    static var allTests = [
        ("testProcessForEnvironment_forProject_true", testProcessForEnvironment_forProject_true),
        ("testProcessForEnvironment_forProject_false", testProcessForEnvironment_forProject_false),
        ("testProcessForEnvironment_forFastlane_true", testProcessForEnvironment_forFastlane_true),
        ("testProcessForEnvironment_forFastlane_false", testProcessForEnvironment_forFastlane_false)
    ]
}
