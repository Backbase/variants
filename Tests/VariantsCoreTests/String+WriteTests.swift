//
//  String+WriteTests.swift
//  VariantsCoreTests
//
//  Created by Giuseppe Deraco on 24/11/2020.
//

import XCTest
import PathKit
@testable import VariantsCore

class String_WriteTests: XCTestCase {

    func testWrite_appendLine() throws {
        var hello = "hello"
        hello.appendLine("world")
        XCTAssertEqual(hello,"helloworld\n")
    }

}
