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
        logger: Logger.shared,
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
        XCTAssertEqual(parametersFactoryMock.createParametersCache.count, 0)
        XCTAssertEqual(xcFactoryMock.createConfigCache.count, 1)
        XCTAssertEqual(xcFactoryMock.createConfigCache.first?.variant.name, "default")
        
        XCTAssertNoThrow(try project.setup(spec: specPath.string, skipFastlane: false, verbose: true))
        XCTAssertEqual(xcFactoryMock.createConfigCache.count, 2)
        XCTAssertEqual(parametersFactoryMock.createParametersCache.count, 1)
        XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.file.string, "fastlane/parameters/variants_params.rb")
        XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.parameters.count, 1)
        XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.parameters.first?.name, "STORE_DESTINATION")
        XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.parameters.first?.value, "appstore")
        XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.parameters.first?.destination, .fastlane)
        XCTAssertEqual(parametersFactoryMock.createMatchFileCache.count, 1)
    }
    
    func testProject_list() {
        let xcFactoryMock = MockXCcodeConfigFactory(logLevel: true)
        let parametersFactoryMock = MockFastlaneFactory()
        let project = iOSProject(
            specHelper: specHelperMock,
            configFactory: xcFactoryMock,
            parametersFactory: parametersFactoryMock,
            yamlParser: YamlParser()
        )
        
        guard let specPath = specPath(resourcePath: "Resources/valid_variants", withType: "yml") else {
            return XCTFail("Couldn't find valid_variants.yml file.")
        }
        
        let variants = try? project.list(spec: specPath.string)
        XCTAssertNotNil(variants)
        XCTAssertEqual(variants?.count, 3)
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
                XCTAssertEqual(validationError.description, "Variant '\(inexistentVariant)' not found.")
            }
        }
        
        let betaVariant = "beta"
        XCTAssertNoThrow(try project.switch(to: betaVariant, spec: specPath.string, verbose: true))
        XCTAssertEqual(parametersFactoryMock.createParametersCache.count, 1)
        XCTAssertEqual(parametersFactoryMock.createParametersCache.first?.parameters.count, 2)
        XCTAssertEqual(parametersFactoryMock.createMatchFileCache.count, 1)
        XCTAssertEqual(xcFactoryMock.createConfigCache.count, 1)
        XCTAssertEqual(xcFactoryMock.createConfigCache.first?.variant.name, "BETA")
        
        let stgVariant = "stg"
        XCTAssertNoThrow(try project.switch(to: stgVariant, spec: specPath.string, verbose: true))
        XCTAssertEqual(parametersFactoryMock.createParametersCache.count, 2)
        XCTAssertEqual(parametersFactoryMock.createParametersCache.last?.parameters.count, 1)
        XCTAssertEqual(parametersFactoryMock.createMatchFileCache.count, 2)
        XCTAssertEqual(xcFactoryMock.createConfigCache.count, 2)
        XCTAssertEqual(xcFactoryMock.createConfigCache.last?.variant.name, "STG")
    }
    
    func testProject_setup_missingiOSConfiguration() {
        let xcFactoryMock = MockXCcodeConfigFactory(logLevel: true)
        let parametersFactoryMock = MockFastlaneFactory()
        
        let project = iOSProject(
            specHelper: specHelperMock,
            configFactory: xcFactoryMock,
            parametersFactory: parametersFactoryMock,
            yamlParser: YamlParser()
        )

        guard let specPath = specPath(resourcePath: "Resources/ios/invalid_missing_ios", withType: "yml") else {
            return XCTFail("Couldn't find invalid_missing_ios.yml file.")
        }
        
        XCTAssertThrowsError(try project.setup(spec: specPath.string, skipFastlane: true, verbose: true), "") { error in
            XCTAssertTrue(error is RuntimeError)
            XCTAssertEqual((error as? RuntimeError)?.description, """
            ❌ Unable to load spec '\(specPath.string)'
            """)
        }
    }
    
    func testProject_setup_fail() {
        let xcFactoryMock = MockXCcodeConfigFactory(logLevel: true)
        let parametersFactoryMock = MockFastlaneFactory()
        
        let project = iOSProject(
            specHelper: specHelperMock,
            configFactory: xcFactoryMock,
            parametersFactory: parametersFactoryMock,
            yamlParser: YamlParser()
        )
        
        guard let path = Bundle(for: type(of: self)).resourcePath else {
            XCTFail("Resource path directory should be not nil")
            return
        }
        
        do {
            try project.setup(spec: Path(path).string, skipFastlane: false, verbose: true)
            XCTFail("Should not succeed, exception throw is expected")
        } catch let error as ValidationError {
            XCTAssertEqual(error.description, "Error: \(path) is a directory path")

            XCTAssertEqual(xcFactoryMock.createConfigCache.count, 0)
            XCTAssertEqual(parametersFactoryMock.createParametersCache.count, 0)
            XCTAssertEqual(parametersFactoryMock.createMatchFileCache.count, 0)
        } catch {
            XCTFail("Caught unknown error \(error)")
        }
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
        ("testProject_switch", testProject_switch),
        ("testProject_setup_fail", testProject_setup_fail),
        ("testProject_setup_missingiOSConfiguration", testProject_setup_missingiOSConfiguration)
    ]
}

// swiftlint:enable type_name
