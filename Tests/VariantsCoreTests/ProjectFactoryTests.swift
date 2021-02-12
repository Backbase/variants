//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import XCTest
@testable import VariantsCore

class ProjectFactoryTests: XCTestCase {

    func test_from() throws {
        XCTAssertEqual(
            ProjectFactory
                .from(platform: .ios, logger: Logger.shared)
                .specHelper.templatePath.string,
            "/ios/variants-template.yml")
        
        XCTAssertEqual(
            ProjectFactory
                .from(platform: .android, logger: Logger.shared)
                .specHelper.templatePath.string,
            "/android/variants-template.yml")
    }

}
