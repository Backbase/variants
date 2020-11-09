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
// swiftlint:disable colon

class iOSProjectTests: XCTestCase {
    func testProject_initialize() {
        let specHelperMock = SpecHelperMock(templatePath: Path("variants-template.yml"))
        let xcFactoryMock = MockXCcodeConfigFactory(logLevel: true)
        let fastlaneFactoryMock = MockFastlaneFactory()
        
        let project = iOSProject(
            specHelper: specHelperMock,
            configFactory: xcFactoryMock,
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
        let xcFactoryMock = MockXCcodeConfigFactory(logLevel: true)
        let fastlaneFactoryMock = MockFastlaneFactory()
        
        let project = iOSProject(
            specHelper: specHelperMock,
            configFactory: xcFactoryMock,
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
            XCTAssertEqual(xcFactoryMock.createConfigCache.count, 1)
            XCTAssertEqual(xcFactoryMock.createConfigCache.first?.variant.name, "default")
            
            XCTAssertNoThrow(try project.setup(spec: spec.string, skipFastlane: false, verbose: true))
            XCTAssertEqual(xcFactoryMock.createConfigCache.count, 2)
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
        let xcFactoryMock = MockXCcodeConfigFactory(logLevel: true)
        let fastlaneFactoryMock = MockFastlaneFactory()
        
        let project = iOSProject(
            specHelper: specHelperMock,
            configFactory: xcFactoryMock,
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
            XCTAssertEqual(xcFactoryMock.createConfigCache.count, 1)
            XCTAssertEqual(xcFactoryMock.createConfigCache.first?.variant.name, "BETA")

            let stgVariant = "stg"
            XCTAssertNoThrow(try project.switch(to: stgVariant, spec: spec.string, verbose: true))
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.count, 2)
            XCTAssertEqual(fastlaneFactoryMock.createParametersCache.last?.parameters.count, 1)
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

class MockXCcodeConfigFactory: XCFactory {
    var writeContentCache: [(content: String, file: Path, force: Bool)] = []
    var writeJSONCache: [(encodableObject: Encodable, file: Path)] = []
    var createConfigCache: [(target: NamedTarget,
                             variant: iOSVariant,
                             xcodeProj: String?,
                             configPath: Path,
                             addToXcodeProj: Bool?)] = []
    
    init(logLevel: Bool = false) {
        logger = Logger(verbose: logLevel)
    }
    
    func write(_ stringContent: String, toFile file: Path, force: Bool) -> (Bool, Path?) {
        writeContentCache.append((content: stringContent, file: file, force: force))
        return (true, file)
    }
    
    func writeJSON<T>(_ encodableObject: T, toFile file: Path) -> (Bool, Path?) where T : Encodable {
        writeJSONCache.append((encodableObject: encodableObject, file: file))
        return (true, file)
    }
    
    func createConfig(with target: NamedTarget,
                      variant: iOSVariant,
                      xcodeProj: String?,
                      configPath: Path,
                      addToXcodeProj: Bool?) {
        createConfigCache.append((target: target,
                                  variant: variant,
                                  xcodeProj: xcodeProj,
                                  configPath: configPath,
                                  addToXcodeProj: addToXcodeProj))
    }
    
    var xcconfigFileName: String = "variants.xcconfig"
    var logger: Logger
}

class MockFastlaneFactory: FastlaneFactory {
    var createParametersCache: [(folder: Path, parameters: [CustomProperty])] = []
    var renderCache: [[CustomProperty]] = []
    var writeCache: [(data: Data, fastlaneParametersFolder: Path)] = []
    
    func createParametersFile(in folder: Path, with parameters: [CustomProperty]) throws {
        createParametersCache.append((folder: folder, parameters: parameters))
    }
    
    func render(parameters: [CustomProperty]) throws -> Data? {
        renderCache.append(parameters)
        return nil
    }
    
    func write(_ data: Data, using fastlaneParametersFolder: Path) throws {
        writeCache.append((data: data, fastlaneParametersFolder: fastlaneParametersFolder))
    }
}

class SpecHelperMock: SpecHelper {
    var generateCache: [Path] = []
    
    override func generate(from path: Path) throws {
        generateCache.append(path)
    }
}
