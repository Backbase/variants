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
            value: "A_SECRET",
            env: true,
            destination: .project
        )
        
        XCTAssertTrue(
            environmentVarProperty.isEnvironmentVariable,
            "`isEnvironmentVariable` should be true as `env` is set to true"
        )
        
        XCTAssertEqual(
            environmentVarProperty.environmentValue,
            "A_SECRET",
            "`environmentValue` should be equal to `value` as `destination` is project"
        )
    }
    
    func testProcessForEnvironment_forProject_false() {
        let environmentVarProperty = CustomProperty(
            name: "A_PROPERTY",
            value: "A_VALUE",
            destination: .project
        )
        
        XCTAssertFalse(
            environmentVarProperty.isEnvironmentVariable,
            "`isEnvironmentVariable` should be false as `env` is not set and defaults to false"
        )
        
        XCTAssertEqual(
            environmentVarProperty.environmentValue,
            environmentVarProperty.value,
            "`environmentValue` should be equal to `value` as `destination` is project and/or `env` isn't set and defaults to false"
        )
    }
    
    func testProcessForEnvironment_forFastlane_true() {
        let environmentVarProperty = CustomProperty(
            name: "AN_ENV_VAR",
            value: "A_SECRET",
            env: true,
            destination: .fastlane
        )
        
        XCTAssertTrue(
            environmentVarProperty.isEnvironmentVariable,
            "`isEnvironmentVariable` should be true as `env` is set to true"
        )
        
        XCTAssertEqual(
            environmentVarProperty.environmentValue,
            "ENV[\"A_SECRET\"]",
            "`environmentValue` should be contained within 'ENV[\"\"]' as `destination` is fastlane and `env` is set to true"
        )
    }
    
    func testProcessForEnvironment_forFastlane_false() {
        let environmentVarProperty = CustomProperty(
            name: "A_PROPERTY",
            value: "A_VALUE",
            destination: .fastlane
        )
        
        XCTAssertFalse(
            environmentVarProperty.isEnvironmentVariable,
            "`isEnvironmentVariable` should be false as `env` is not set and defaults to false"
        )
        
        XCTAssertEqual(
            environmentVarProperty.environmentValue,
            environmentVarProperty.value,
            "`environmentValue` should be equal to `value` as `destination`, as `env` isn't set and defaults to false"
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
                value: "A_SECRET",
                env: true,
                destination: .fastlane
            )
        ]
        
        let fastlaneParameters = propertiesArray
            .filter { $0.destination == .fastlane }
            .map { (property) -> CustomProperty in
                if property.isEnvironmentVariable {
                    return CustomProperty(name: property.name,
                                          value: property.environmentValue,
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
