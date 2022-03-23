//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Abdoelrhman Eaita on 16/09/2021.
//

import XCTest
import PathKit

@testable import VariantsCore

class DataWriteTests: XCTestCase {
    private var readFromFile = Path("readTest.txt")
    private var writeToFile = Path("writeTest.txt")
    
    override func setUpWithError() throws {
        try "".write(to: readFromFile.url, atomically: true, encoding: .utf8)
        try "".write(to: writeToFile.url, atomically: true, encoding: .utf8)
    }
    
    func testAppendFileToFile() throws {
        let data = try Data(contentsOf: readFromFile.url)
        try data.append(fileURL: writeToFile.url)
        XCTAssertEqual(try Data(contentsOf: writeToFile.url), try Data(contentsOf: readFromFile.url))
    }
}
