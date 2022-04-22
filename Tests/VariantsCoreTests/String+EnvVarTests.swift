//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//

import XCTest
import PathKit
@testable import VariantsCore

import Foundation
class StringEnvVarTests: XCTestCase {

    func testAppendLineToPath() throws {
        XCTAssertEqual("hello world", "hello world".extractEnvVarIfAny())
        XCTAssertEqual("", "${{ envVars.something }}".extractEnvVarIfAny())
        setenv("something", "sOmEtHiNg", 1)
        XCTAssertEqual("sOmEtHiNg", "${{ envVars.something }}".extractEnvVarIfAny())
    }
}
