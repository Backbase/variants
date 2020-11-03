//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import XCTest
@testable import VariantsCore

class YamlParserTests: XCTestCase {
    func testExtractConfiguration_invalidSpec() {
        let parser = YamlParser()
        do {
            guard let path = Bundle(for: type(of: self)).path(forResource: "Resources/invalid_variants", ofType: "yml") else { return }
            _ = try parser.extractConfiguration(from: path, platform: .ios)
        } catch {
            XCTAssertTrue(((error as? DecodingError) != nil))
        }
    }
    
    func testExtractConfiguration_valid_iOS() {
        let parser = YamlParser()
        do {
            guard let path = Bundle(for: type(of: self)).path(forResource: "Resources/valid_variants", ofType: "yml") else { return }
            let configuration = try parser.extractConfiguration(from: path, platform: .ios)
            
            XCTAssertNotNil(configuration.ios)
            XCTAssertEqual(configuration.ios?.targets.count, 1)
            XCTAssertEqual(configuration.ios?.targets.first?.value.name, "FrankBank")
            XCTAssertEqual(configuration.ios?.targets.first?.value.bundleId, "com.backbase.frank.ios")
            XCTAssertEqual(configuration.ios?.variants.count, 2)
            XCTAssertEqual(configuration.ios?.variants.first?.name, "default")
            XCTAssertEqual(configuration.ios?.variants.last?.name, "BETA")
            
            let customConfigDefault = configuration.ios?
                .variants.first(where: { $0.name == "default" })?
                .custom?.first(where: { $0.name == "SAMPLE_CONFIG" })
            XCTAssertNotNil(customConfigDefault)
            XCTAssertEqual(customConfigDefault?.value, "Production Value")
            
            let customConfigBeta = configuration.ios?
                .variants.first(where: { $0.name == "BETA" })?
                .custom?.first(where: { $0.name == "SAMPLE_CONFIG" })
            XCTAssertNotNil(customConfigBeta)
            XCTAssertEqual(customConfigBeta?.value, "BETA Value")
            
        } catch {
            XCTAssertTrue(((error as? DecodingError) == nil))
        }
    }
    
    func testExtractConfiguration_valid_android() {
        let parser = YamlParser()
        do {
            guard let path = Bundle(for: type(of: self)).path(forResource: "Resources/valid_variants", ofType: "yml") else { return }
            let configuration = try parser.extractConfiguration(from: path, platform: .android)
            
            XCTAssertNotNil(configuration.android)
            XCTAssertEqual(configuration.android?.appName, "FrankBank")
            XCTAssertEqual(configuration.android?.appIdentifier, "com.backbase.frank")
            XCTAssertEqual(configuration.android?.path, "path/to/android-project/")
            XCTAssertEqual(configuration.android?.variants.count, 2)
            XCTAssertEqual(configuration.android?.variants.first?.name, "default")
            XCTAssertEqual(configuration.android?.variants.last?.name, "test")
            
            let customConfigDefault = configuration.android?
                .variants.first(where: { $0.name == "default" })?
                .custom?.first(where: { $0.name == "SAMPLE_ENV" })
            XCTAssertNotNil(customConfigDefault)
            XCTAssertEqual(customConfigDefault?.value, "Sample Environment Config")
            XCTAssertEqual(customConfigDefault?.destination, .envVar)
            
            let customConfigTest = configuration.android?
                .variants.first(where: { $0.name == "test" })?
                .custom?.first(where: { $0.name == "SAMPLE_FASTLANE" })
            XCTAssertNotNil(customConfigTest)
            XCTAssertEqual(customConfigTest?.value, "Sample Fastlane Config")
            XCTAssertEqual(customConfigTest?.destination, .fastlane)
        } catch {
            XCTAssertTrue(((error as? DecodingError) == nil))
        }
    }
    
    static var allTests = [
        ("testExtractConfiguration_invalidSpec", testExtractConfiguration_invalidSpec),
        ("testExtractConfiguration_valid_iOS", testExtractConfiguration_valid_iOS),
        ("testExtractConfiguration_valid_android", testExtractConfiguration_valid_android)
    ]
}
