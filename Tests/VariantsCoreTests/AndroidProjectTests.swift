//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Will Nasby
//

import XCTest
import PathKit
import ArgumentParser
@testable import VariantsCore

class AndroidProjectTests: XCTestCase {
    let specHelperMock = SpecHelperMock(
        logger: Logger.shared,
        templatePath: Path("variants-template.yml"),
        userInputSource: interactiveShell,
        userInput: { "yes" }
    )
    
    func testProject_initialize() {
        let gradleFactoryMock = MockGradleScriptFactory()
        let fastlaneFactoryMock = MockFastlaneFactory()

        let project = AndroidProject(
            specHelper: specHelperMock,
            gradleFactory: gradleFactoryMock,
            parametersFactory: fastlaneFactoryMock,
            yamlParser: YamlParser()
        )

        XCTAssertNoThrow(try project.initialize(verbose: true))
        XCTAssertEqual(specHelperMock.generateCache.count, 1)
        XCTAssertNoThrow(try project.initialize(verbose: true))
        XCTAssertEqual(specHelperMock.generateCache.count, 2)
    }
    
    func testProject_setup() {
        let gradleFactoryMock = MockGradleScriptFactory()
        let fastlaneFactoryMock = MockFastlaneFactory()

        let project = AndroidProject(
            specHelper: specHelperMock,
            gradleFactory: gradleFactoryMock,
            parametersFactory: fastlaneFactoryMock,
            yamlParser: YamlParser()
        )
        
        let inexistentSpecPath = "inexistent_variants_config.yml"
        XCTAssertThrowsError(try project.setup(spec: inexistentSpecPath, skipFastlane: true, verbose: true),
                             "Spec doesn't exist") { (error) in
            XCTAssertNotNil(error as? RuntimeError)
            if let runtimeError = error as? RuntimeError {
                XCTAssertEqual(runtimeError.description, """
                    ❌ Unable to load your YAML spec
                    """)
            }
        }

        guard let specPath = specPath(resourcePath: "Resources/valid_variants", withType: "yml") else {
            return XCTFail("Couldn't find valid_variants.yml file.")
        }
        
        XCTAssertNoThrow(try project.setup(spec: specPath.string, skipFastlane: true, verbose: true))
        XCTAssertEqual(fastlaneFactoryMock.createParametersCache.count, 0)
        XCTAssertEqual(gradleFactoryMock.createScriptCache.count, 1)

        XCTAssertNoThrow(try project.setup(spec: specPath.string, skipFastlane: false, verbose: true))
        XCTAssertEqual(gradleFactoryMock.createScriptCache.count, 2)
        XCTAssertEqual(gradleFactoryMock.createScriptCache.first?.variant.name, "default")
        XCTAssertEqual(fastlaneFactoryMock.createParametersCache.count, 1)
        
        let fastlaneFactoryLastRequest = fastlaneFactoryMock.createParametersCache.last
        XCTAssertEqual(fastlaneFactoryLastRequest?.file.string, "fastlane/parameters/variants_params.rb")
        XCTAssertEqual(fastlaneFactoryLastRequest?.parameters.count, 4)
        XCTAssertEqual(fastlaneFactoryLastRequest?.parameters.first?.name, "SAMPLE_PROJECT")
        XCTAssertEqual(fastlaneFactoryLastRequest?.parameters.first?.value, "Sample Project Default Config")
        XCTAssertEqual(fastlaneFactoryLastRequest?.parameters.first?.destination, .project)
        
        let packageProperty = fastlaneFactoryMock.createParametersCache
            .last?.parameters.first(where: { $0.name == "PACKAGE_NAME" })
        XCTAssertNotNil(packageProperty)
        if let packageProperty = packageProperty {
            XCTAssertEqual(packageProperty.value, "com.backbase.frank")
            XCTAssertEqual(packageProperty.destination, .fastlane)
        }
    }
    
    func testProject_list() {
        let gradleFactoryMock = MockGradleScriptFactory()
        let fastlaneFactoryMock = MockFastlaneFactory()

        let project = AndroidProject(
            specHelper: specHelperMock,
            gradleFactory: gradleFactoryMock,
            parametersFactory: fastlaneFactoryMock,
            yamlParser: YamlParser()
        )
        
        let inexistentSpecPath = "inexistent_variants_config.yml"
        XCTAssertThrowsError(try project.setup(spec: inexistentSpecPath, skipFastlane: true, verbose: true),
                             "Spec doesn't exist") { (error) in
            XCTAssertNotNil(error as? RuntimeError)
            if let runtimeError = error as? RuntimeError {
                XCTAssertEqual(runtimeError.description, """
                    ❌ Unable to load your YAML spec
                    """)
            }
        }

        guard let specPath = specPath(resourcePath: "Resources/valid_variants", withType: "yml") else {
            return XCTFail("Couldn't find valid_variants.yml file.")
        }
        
        let variants = try? project.list(spec: specPath.string)
        XCTAssertNotNil(variants)
        XCTAssertEqual(variants?.count, 2)
    }
    
    func testProject_switch() {
        let gradleFactoryMock = MockGradleScriptFactory()
        let fastlaneFactoryMock = MockFastlaneFactory()

        let project = AndroidProject(
            specHelper: specHelperMock,
            gradleFactory: gradleFactoryMock,
            parametersFactory: fastlaneFactoryMock,
            yamlParser: YamlParser()
        )

        // Path to Variants spec is wrong
        let inexistentSpecPath = "inexistent_variants_config.yml"
        let inexistentVariant = "inexistent_variant_name"
        XCTAssertThrowsError(try project.switch(to: inexistentVariant, spec: inexistentSpecPath, verbose: true),
                             "Spec doesn't exist") { (error) in
            XCTAssertNotNil(error as? RuntimeError)
            if let runtimeError = error as? RuntimeError {
                XCTAssertEqual(runtimeError.description, """
                    ❌ Unable to load your YAML spec
                    """)
            }
        }

        guard let specPath = specPath(resourcePath: "Resources/valid_variants", withType: "yml") else {
            return XCTFail("Couldn't find valid_variants.yml file.")
        }
        
        // Variant 'variant' doesn't exist
        XCTAssertThrowsError(try project.switch(to: inexistentVariant, spec: specPath.string, verbose: true),
                             "Variant doesn't exist") { (error) in
            XCTAssertNotNil(error as? ValidationError)
            if let validationError = error as? ValidationError {
                XCTAssertEqual(validationError.description, """
                    Variant '\(inexistentVariant)' not found.
                    """)
            }
        }

        let testVariant = "test"
        XCTAssertNoThrow(try project.switch(to: testVariant, spec: specPath.string, verbose: true))
        XCTAssertEqual(fastlaneFactoryMock.createParametersCache.count, 1)
        XCTAssertEqual(fastlaneFactoryMock.createParametersCache.first?.parameters.count, 5)
        XCTAssertEqual(gradleFactoryMock.createScriptCache.count, 1)
        XCTAssertEqual(gradleFactoryMock.createScriptCache.first?.variant.name, "test")

        let defaultVariant = "default"
        XCTAssertNoThrow(try project.switch(to: defaultVariant, spec: specPath.string, verbose: true))
        XCTAssertEqual(fastlaneFactoryMock.createParametersCache.count, 2)
        XCTAssertEqual(fastlaneFactoryMock.createParametersCache.last?.parameters.count, 4)
        XCTAssertEqual(gradleFactoryMock.createScriptCache.count, 2)
        XCTAssertEqual(gradleFactoryMock.createScriptCache.last?.variant.name, "default")
    }
    
    private func specPath(resourcePath: String, withType fileType: String) -> Path? {
        guard let path = Bundle(for: type(of: self))
                .path(forResource: resourcePath, ofType: fileType)
        else { return nil }
    
        return Path(path)
    }
    
    static var allTests = [
        ("testProject_initialize", testProject_initialize),
        ("testProject_setup", testProject_setup),
        ("testProject_list", testProject_list),
        ("testProject_switch", testProject_switch)
    ]
}
