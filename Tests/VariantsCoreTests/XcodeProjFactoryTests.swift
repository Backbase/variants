//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Abdoelrhman Eaita on 24/09/2021.
//

import XCTest
import PathKit

@testable import VariantsCore

class XcodeProjFactoryTests: XCTestCase {
    
    func testProjectPath() {
        let sut = XcodeProjFactory()
        XCTAssertEqual(sut.projectPath(), "Test.xcodeproj/")
    }
    
    func testApplicationData() {
        let sut = XcodeProjFactory()
        XCTAssertEqual(sut.applicationData(), [VariantsCore.iOSProjectKey.project: "Test"])
    }
}
