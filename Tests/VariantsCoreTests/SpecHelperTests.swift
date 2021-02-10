//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import XCTest
import PathKit
@testable import VariantsCore

class SpecHelperTests: XCTestCase {
    let correctTemplatePath = Path("variants-template.yml")
    let incorrectTemplatePath = Path("unknown-variants-template.yml")
    let silentUserInput = UserInput { false }
    
    func testGenerateSpec_basePathShouldNotBeNil() {
        XCTAssertNotNil(basePath())
    }
    
    func testGenerateSpec_incorrectPath() {
        if let basePath = basePath() {
            let variantsPath = Path("./variants.yml")
            if variantsPath.exists {
                XCTAssertNoThrow(try variantsPath.delete())
            }
            
            let specHelper = iOSSpecHelper(
                templatePath: incorrectTemplatePath,
                userInput: silentUserInput
            )
            
            XCTAssertThrowsError(
                try specHelper.generate(from: basePath),
                "Attempt to use an invalid path"
            ) { error in
                XCTAssertEqual(error.localizedDescription, """
                    The file “unknown-variants-template.yml” couldn’t be opened because there is no such file.
                    """)
            }
        }
    }
    
    func testGenerateSpec_correctPath() {
        if let basePath = basePath() {
            let variantsPath = Path("./variants.yml")
            if variantsPath.exists {
                XCTAssertNoThrow(try variantsPath.delete())
            }
            let specHelper = iOSSpecHelper(
                templatePath: correctTemplatePath,
                userInput: silentUserInput
            )
            XCTAssertNoThrow(try specHelper.generate(from: basePath))
            
            XCTAssertTrue(variantsPath.exists)
        }
    }
    
    private func basePath() -> Path? {
        guard let path = Bundle(for: type(of: self))
                .path(forResource: "Resources/variants-template", ofType: "yml")
        else { return nil }
        
        let basePath = Path(path)
        return Path(components: basePath.components.dropLast())
    }
    
    static var allTests = [
        ("testGenerateSpec_basePathShouldNotBeNil", testGenerateSpec_basePathShouldNotBeNil),
        ("testGenerateSpec_incorrectPath", testGenerateSpec_incorrectPath),
        ("testGenerateSpec_correctPath", testGenerateSpec_correctPath)
    ]
}
