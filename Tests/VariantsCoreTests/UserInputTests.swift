//
//  UserInputTests.swift
//  VariantsCoreTests
//
//  Created by Roman Huti on 17.11.2022.
//

import XCTest
@testable import VariantsCore

final class UserInputTests: XCTestCase {
    
    private var sut = interactiveShell
    
    func testInteractiveShellInputValidYes() {
        XCTAssertTrue(sut.doesUserGrantPermissionToOverrideSpec({ "yes" }))
        XCTAssertTrue(sut.doesUserGrantPermissionToOverrideSpec({ "YeS" }))
        XCTAssertTrue(sut.doesUserGrantPermissionToOverrideSpec({ "Y" }))
        XCTAssertTrue(sut.doesUserGrantPermissionToOverrideSpec({ "y" }))
    }
    
    func testInteractiveShellInputValidNo() {
        XCTAssertFalse(sut.doesUserGrantPermissionToOverrideSpec({ "no" }))
        XCTAssertFalse(sut.doesUserGrantPermissionToOverrideSpec({ "N" }))
        XCTAssertFalse(sut.doesUserGrantPermissionToOverrideSpec({ "nO" }))
        XCTAssertFalse(sut.doesUserGrantPermissionToOverrideSpec({ "n" }))
    }
    
    func testInteractiveShellInputOnFailValidationRecursionHappens() {
        var executionCounter = 0
        sut = UserInputSource { input -> Bool in
            return interactiveShellInput(
                input,
                with: "'variants.yml' spec already exists! Should we override it?",
                suggestion: "[Y]es / [N]o",
                validation: { _ -> Bool in
                    executionCounter += 1
                    return executionCounter > 2
                }
            )
        }

        XCTAssertFalse(sut.doesUserGrantPermissionToOverrideSpec({ "" }))
        XCTAssertEqual(executionCounter, 3)
    }
}
