//
//  Data+WriteTests.swift
//  VariantsCoreTests
//
//  Created by Abdoelrhman Eaita on 16/09/2021.
//

import XCTest
import PathKit

@testable import VariantsCore

class DataWriteTests: XCTestCase {
    private var writeToFile = Path("writeTest.txt")
    private var readFromFile = Path("variants_params_template.rb")
    
    override func tearDownWithError() throws {
        try "".write(to: writeToFile.url, atomically: true, encoding: .utf8)
    }
    
    func testAppendFileToFile() throws {
        let data = try Data(contentsOf: readFromFile.url)
        try data.append(fileURL: writeToFile.url)
        XCTAssertEqual(try Data(contentsOf: writeToFile.url), try Data(contentsOf: readFromFile.url))
    }
}
