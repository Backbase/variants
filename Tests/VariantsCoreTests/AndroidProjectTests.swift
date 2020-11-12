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
    func testProject_initialize() {
        let specHelperMock = SpecHelperMock(templatePath: Path("variants-template.yml"))
        let gradleFactoryMock = MockGradleScriptFactory()
        let fastlaneFactoryMock = MockFastlaneFactory()

        let project = AndroidProject(
            specHelper: specHelperMock,
            gradleFactory: gradleFactoryMock,
            fastlaneFactory: fastlaneFactoryMock,
            yamlParser: YamlParser()
        )

        XCTAssertNoThrow(try project.initialize(verbose: true))
        XCTAssertEqual(specHelperMock.generateCache.count, 1)
        XCTAssertNoThrow(try project.initialize(verbose: true))
        XCTAssertEqual(specHelperMock.generateCache.count, 2)
    }
    
    func testProject_setup() {
        let specHelperMock = SpecHelperMock(templatePath: Path("variants-template.yml"))
        let gradleFactoryMock = MockGradleScriptFactory()
        let fastlaneFactoryMock = MockFastlaneFactory()

        let project = AndroidProject(
            specHelper: specHelperMock,
            gradleFactory: gradleFactoryMock,
            fastlaneFactory: fastlaneFactoryMock,
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
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.count, 0)
            XCTAssertEqual(gradleFactoryMock.createScriptCache.count, 1)
            XCTAssertEqual(gradleFactoryMock.createScriptCache.first?.variant.name, "default")

            XCTAssertNoThrow(try project.setup(spec: spec.string, skipFastlane: false, verbose: true))
            XCTAssertEqual(gradleFactoryMock.createScriptCache.count, 2)
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.count, 1)
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.last?.folder.string, "fastlane/parameters/")
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.last?.parameters.count, 1)
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.last?.parameters.first?.name, "STORE_DESTINATION")
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.last?.parameters.first?.value, "appstore")
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.last?.parameters.first?.destination, .fastlane)
        }
    }
    
    func testProject_switch() {
        let specHelperMock = SpecHelperMock(templatePath: Path("variants-template.yml"))
        let gradleFactoryMock = MockGradleScriptFactory()
        let fastlaneFactoryMock = MockFastlaneFactory()

        let project = AndroidProject(
            specHelper: specHelperMock,
            gradleFactory: gradleFactoryMock,
            fastlaneFactory: fastlaneFactoryMock,
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
                    XCTAssertEqual(validationError.description, """
                        Variant '\(inexistentVariant)' not found.
                        """)
                }
            }

            let betaVariant = "beta"
            XCTAssertNoThrow(try project.switch(to: betaVariant, spec: spec.string, verbose: true))
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.count, 1)
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.first?.parameters.count, 2)
            XCTAssertEqual(gradleFactoryMock.createScriptCache.count, 1)
            XCTAssertEqual(gradleFactoryMock.createScriptCache.first?.variant.name, "BETA")

            let stgVariant = "stg"
            XCTAssertNoThrow(try project.switch(to: stgVariant, spec: spec.string, verbose: true))
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.count, 2)
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.last?.parameters.count, 1)
            XCTAssertEqual(gradleFactoryMock.createScriptCache.count, 2)
            XCTAssertEqual(gradleFactoryMock.createScriptCache.last?.variant.name, "STG")
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

class MockGradleScriptFactory: GradleFactory {
    var writeContentCache: [(data: Data, gradleScriptFolder: Path)] = []
    var renderContentCache: [(configuration: AndroidConfiguration,
                            variant: AndroidVariant)] = []
    var createScriptCache: [(configuration: AndroidConfiguration,
                             variant: AndroidVariant)] = []
    
    init(templatePath: Path? = try? TemplateDirectory().path) {
        self.templatePath = templatePath
    }
    
    func createScript(with configuration: AndroidConfiguration, variant: AndroidVariant) {
        createScriptCache.append((configuration: configuration, variant: variant))
    }
    
    func render(with configuration: AndroidConfiguration, variant: AndroidVariant) throws -> Data? {
        renderContentCache.append((configuration: configuration, variant: variant))
        return nil
    }
    
    func write(_ data: Data, using gradleScriptFolder: Path) throws {
        writeContentCache.append((data: data, gradleScriptFolder: gradleScriptFolder))
    }
    
    private let templatePath: Path?
}
//
//class MockFastlaneFactory: FastlaneFactory {
//    var createParametersCache: [(folder: Path, parameters: [CustomProperty])] = []
//    var renderCache: [[CustomProperty]] = []
//    var writeCache: [(data: Data, fastlaneParametersFolder: Path)] = []
//
//    func createParametersFile(in folder: Path, with parameters: [CustomProperty]) throws {
//        createParametersCache.append((folder: folder, parameters: parameters))
//    }
//
//    func render(parameters: [CustomProperty]) throws -> Data? {
//        renderCache.append(parameters)
//        return nil
//    }
//
//    func write(_ data: Data, using fastlaneParametersFolder: Path) throws {
//        writeCache.append((data: data, fastlaneParametersFolder: fastlaneParametersFolder))
//    }
//}
//
//class SpecHelperMock: SpecHelper {
//    var generateCache: [Path] = []
//
//    override func generate(from path: Path) throws {
//        generateCache.append(path)
//    }
//}
