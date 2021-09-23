//
//  Path+SafeJoinTests.swift
//  VariantsCoreTests
//
//  Created by Abdoelrhman Eaita on 20/09/2021.
//

import XCTest
import PathKit

@testable import VariantsCore


class Path_SafeJoinTests: XCTestCase {

    
    func testSafelyJoinPaths() throws {
        let path = Path("varients")
        let newPath = Path("fastlane")
        let combined = try path.safeJoin(path: newPath)
        XCTAssertTrue(combined.abbreviate().url.absoluteString.contains("varients/fastlane"))
    }
    
    func testJoiningSuspiciousPaths() throws {
        let path = Path("varients/fastlane")
        let newPath = Path("/public/tmp/varients")
        var thrownError: Error?
        XCTAssertThrowsError(try path.safeJoin(path: newPath)) {
            thrownError = $0
        }
        
        XCTAssertTrue(thrownError is SuspiciousFileOperation)
    }

}
