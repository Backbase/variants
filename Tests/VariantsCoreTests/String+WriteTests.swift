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

    func testWrite_appendLine() throws {
        var hello = "hello"
        hello.appendLine("world")
        XCTAssertEqual(hello, "helloworld\n")
    }

}
