//
//  ProjectFactoryTests.swift
//  VariantsCoreTests
//
//  Created by Giuseppe Deraco on 24/11/2020.
//

import XCTest
@testable import VariantsCore

class ProjectFactoryTests: XCTestCase {

    func test_from() throws {
        XCTAssertEqual(
            ProjectFactory.from(platform: .ios).specHelper.templatePath.string,
            "/ios/variants-template.yml")
        
        XCTAssertEqual(
            ProjectFactory.from(platform: .android).specHelper.templatePath.string,
            "/android/variants-template.yml")
    }

}
