//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import XCTest
import PathKit
@testable import VariantsCore

class StringWriteTests: XCTestCase {
    static let filePath = Path("writeTest.txt")
    
    override func tearDownWithError() throws {
        try "".write(to: StringWriteTests.filePath.url, atomically: true, encoding: .utf8)
    }

    func testAppendLineToPath() throws {
        let testText = "hello world"
        try testText.appendLine(to: StringWriteTests.filePath)
        let fileString = try String(contentsOf: StringWriteTests.filePath.url)
        let testTextWithLine = "\(testText)\n"
        XCTAssertEqual(fileString, testTextWithLine)
    }
    
    func testWrite_appendLineToString() throws {
        var hello = "hello"
        hello.appendLine("world")
        XCTAssertEqual(hello, "helloworld\n")
    }
    
    func testAppendLineToURL() throws {
        let testText = "hello world"
        try testText.appendLineToURL(fileURL: StringWriteTests.filePath.url)
        let fileString = try String(contentsOf: StringWriteTests.filePath.url)
        let testTextWithLine = "\(testText)\n"
        XCTAssertEqual(fileString, testTextWithLine)
    }

    func testAppendToURL() throws {
        let testText = "hello world"
        try testText.appendToURL(fileURL: StringWriteTests.filePath.url)
        let fileString = try String(contentsOf: StringWriteTests.filePath.url)
        XCTAssertEqual(fileString, testText)
    }
}
