//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import XCTest
import PathKit
import ArgumentParser
@testable import VariantsCore
// swiftlint:disable type_name

class iOSProjectTests: XCTestCase {
    let specHelperMock = SpecHelperMock(
        templatePath: Path("variants-template.yml"),
        userInputSource: interactiveShell,
        userInput: { "yes" }
    )
    
    func testProject_initialize() {
        let xcFactoryMock = MockXCcodeConfigFactory(logLevel: true)
        let parametersFactoryMock = MockFastlaneFactory()
        
        let project = iOSProject(
            specHelper: specHelperMock,
            configFactory: xcFactoryMock,
            parametersFactory: parametersFactoryMock,
            yamlParser: YamlParser()
        )
        
        XCTAssertNoThrow(try project.initialize(verbose: true))
        XCTAssertEqual(specHelperMock.generateCache.count, 1)
        XCTAssertNoThrow(try project.initialize(verbose: true))
        XCTAssertEqual(specHelperMock.generateCache.count, 2)
    }
    
    func testProject_setup() {
        let xcFactoryMock = MockXCcodeConfigFactory(logLevel: true)
        let parametersFactoryMock = MockFastlaneFactory()
        
        let project = iOSProject(
            specHelper: specHelperMock,
            configFactory: xcFactoryMock,
            parametersFactory: parametersFactoryMock,
            yamlParser: YamlParser()
        )
        
        let wrongSpecPath = "wrong_variants.yml"
        XCTAssertThrowsError(try project.setup(spec: wrongSpecPath, skipFastlane: true, verbose: true),
                             "Spec doesn't exist") { (error) in
            XCTAssertNotNil(error as? RuntimeError)
            if let runtimeError = error as? RuntimeError {
                XCTAssertEqual(runtimeError.description, """
                    ❌ Unable to load your YAML spec
                    """)
            }
        }
        
        XCTAssertNotNil(specPath())
        if let spec = specPath() {
            XCTAssertNoThrow(try project.setup(spec: spec.string, skipFastlane: true, verbose: true))
            XCTAssertEqual(parametersFactoryMock.createParametersCache.count, 0)
            XCTAssertEqual(xcFactoryMock.createConfigCache.count, 1)
            XCTAssertEqual(xcFactoryMock.createConfigCache.first?.variant.name, "default")
            
            XCTAssertNoThrow(try project.setup(spec: spec.string, skipFastlane: false, verbose: true))
            XCTAssertEqual(xcFactoryMock.createConfigCache.count, 2)
            XCTAssertEqual(parametersFactoryMock.createParametersCache.count, 1)
            XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.file.string, "fastlane/parameters/variants_params.rb")
            XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.parameters.count, 1)
            XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.parameters.first?.name, "STORE_DESTINATION")
            XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.parameters.first?.value, "appstore")
            XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.parameters.first?.destination, .fastlane)
            XCTAssertEqual(parametersFactoryMock.createMatchFileCache.count, 1)
        }
    }
    
    func testProject_switch() {
        let xcFactoryMock = MockXCcodeConfigFactory(logLevel: true)
        let parametersFactoryMock = MockFastlaneFactory()
        
        let project = iOSProject(
            specHelper: specHelperMock,
            configFactory: xcFactoryMock,
            parametersFactory: parametersFactoryMock,
            yamlParser: YamlParser()
        )
        
        // Path to Variants spec is wrong
        let wrongSpecPath = "wrong_variants.yml"
        let inexistentVariant = "variant"
        XCTAssertThrowsError(try project.switch(to: inexistentVariant, spec: wrongSpecPath, verbose: true),
                             "Spec doesn't exist") { (error) in
            XCTAssertNotNil(error as? RuntimeError)
            if let runtimeError = error as? RuntimeError {
                XCTAssertEqual(runtimeError.description, """
                    ❌ Unable to load your YAML spec
                    """)
            }
        }
        
        XCTAssertNotNil(specPath())
        if let spec = specPath() {
            // Variant 'variant' doesn't exist
            XCTAssertThrowsError(try project.switch(to: inexistentVariant, spec: spec.string, verbose: true),
                                 "Variant doesn't exist") { (error) in
                XCTAssertNotNil(error as? ValidationError)
                if let validationError = error as? ValidationError {
                    XCTAssertEqual(validationError.description, "Variant '\(inexistentVariant)' not found.")
                }
            }
            
            let betaVariant = "beta"
            XCTAssertNoThrow(try project.switch(to: betaVariant, spec: spec.string, verbose: true))
            XCTAssertEqual(parametersFactoryMock.createParametersCache.count, 1)
            XCTAssertEqual(parametersFactoryMock.createParametersCache.first?.parameters.count, 2)
            XCTAssertEqual(parametersFactoryMock.createMatchFileCache.count, 1)
            XCTAssertEqual(xcFactoryMock.createConfigCache.count, 1)
            XCTAssertEqual(xcFactoryMock.createConfigCache.first?.variant.name, "BETA")
            
            let stgVariant = "stg"
            XCTAssertNoThrow(try project.switch(to: stgVariant, spec: spec.string, verbose: true))
            XCTAssertEqual(parametersFactoryMock.createParametersCache.count, 2)
            XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.parameters.count, 1)
            XCTAssertEqual(parametersFactoryMock.createMatchFileCache.count, 2)
            XCTAssertEqual(xcFactoryMock.createConfigCache.count, 2)
            XCTAssertEqual(xcFactoryMock.createConfigCache.last?.variant.name, "STG")
        }
    }
    
    private func specPath() -> Path? {
        guard let path = Bundle(for: type(of: self))
                .path(forResource: "Resources/valid_variants", ofType: "yml")
        else { return nil }
    
        return Path(path)
    }
    
    static var allTests = [
        ("testProject_initialize", testProject_initialize),
        ("testProject_setup", testProject_setup),
        ("testProject_switch", testProject_switch)
    ]
}
