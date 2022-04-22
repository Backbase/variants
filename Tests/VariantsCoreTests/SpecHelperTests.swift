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
    let xcodeProjectPath = Path("./Test.xcodeproj")
    let gradleProjectPath = Path("./build.gradle")
    
    override func setUp() async throws {
        if !xcodeProjectPath.exists {
            try xcodeProjectPath.mkpath()
        }
        if !xcodeProjectPath.exists {
            try xcodeProjectPath.mkpath()
        }
    }
    
    override func tearDown() async throws {
        if xcodeProjectPath.exists {
            try xcodeProjectPath.delete()
        }
        
        if gradleProjectPath.exists {
            try gradleProjectPath.delete()
        }
    }

    func testGenerateSpec_basePathShouldNotBeNil() {
        XCTAssertNotNil(basePath())
    }
    
    func testGenerateSpec_incorrectPath() {
        if let basePath = basePath() {
            let specHelper = iOSSpecHelper(
                logger: Logger.shared,
                templatePath: incorrectTemplatePath,
                userInputSource: interactiveShell,
                userInput: { "yes" }
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
            let specHelper = iOSSpecHelper(
                logger: Logger.shared,
                templatePath: correctTemplatePath,
                userInputSource: interactiveShell,
                userInput: { "yes" }
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
