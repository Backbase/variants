//
//  StandardOutputStreamTests.swift
//  VariantsCoreTests
//
//  Created by Abdoelrhman Eaita on 27/09/2021.
//

import XCTest

@testable import VariantsCore

class StandardOutputStreamTests: XCTestCase {

    func testWritingToFileHandler() throws {
        let output = StandardOutputStream(fileHandler: .standardOutput)
        
        output.write("test writing to output file")
        
    }
    
    func testWritingBadStringToOutput() throws {
        let test = "this will fail as a UTF8 🤟🏻"
        let output = StandardOutputStream(fileHandler: .standardError)
        output.write(test)
    }

}
