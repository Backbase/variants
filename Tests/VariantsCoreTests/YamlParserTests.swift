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
            XCTAssertEqual(customConfigDefault?.destination, .project)
            
            let customConfigBeta = configuration.ios?
                .variants.first(where: { $0.name == "BETA" })?
                .custom?.first(where: { $0.name == "SAMPLE_CONFIG" })
            XCTAssertNotNil(customConfigBeta)
            XCTAssertEqual(customConfigBeta?.value, "BETA Value")
            XCTAssertEqual(customConfigBeta?.destination, .fastlane)
            
            let customConfigGlobal = configuration.ios?
                .custom?.first(where: { $0.name == "SAMPLE_GLOBAL" })
            XCTAssertNotNil(customConfigGlobal)
            XCTAssertEqual(customConfigGlobal?.value, "GLOBAL Value iOS")
            XCTAssertEqual(customConfigGlobal?.destination, .project)
            
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
                .custom?.first(where: { $0.name == "SAMPLE_PROJECT" })
            XCTAssertNotNil(customConfigDefault)
            XCTAssertEqual(customConfigDefault?.value, "Sample Project Default Config")
            XCTAssertEqual(customConfigDefault?.destination, .project)
            
            let customConfigTest = configuration.android?
                .variants.first(where: { $0.name == "test" })?
                .custom?.first(where: { $0.name == "SAMPLE_FASTLANE" })
            XCTAssertNotNil(customConfigTest)
            XCTAssertEqual(customConfigTest?.value, "Sample Fastlane Config")
            XCTAssertEqual(customConfigTest?.destination, .fastlane)
            
            let customConfigGlobal = configuration.android?
                .custom?.first(where: { $0.name == "SAMPLE_GLOBAL" })
            XCTAssertNotNil(customConfigGlobal)
            XCTAssertEqual(customConfigGlobal?.value, "GLOBAL Value Android")
            XCTAssertEqual(customConfigGlobal?.destination, .project)
        } catch {
            XCTAssertTrue(((error as? DecodingError) == nil))
        }
    }
    
    func testStoreDestination_iOS() {
        let storeDestinationAppCenter = CustomProperty(
            name: "STORE_DESTINATION",
            value: iOSVariant.Destination.appCenter.rawValue,
            destination: .fastlane
        )
        
        let storeDestinationAppStore = CustomProperty(
            name: "STORE_DESTINATION",
            value: iOSVariant.Destination.appStore.rawValue,
            destination: .fastlane
        )
        
        let parser = YamlParser()
        do {
            guard let path = Bundle(for: type(of: self)).path(forResource: "Resources/valid_variants", ofType: "yml") else { return }
            let configuration = try parser.extractConfiguration(from: path, platform: .ios)
            
            XCTAssertEqual(configuration.ios?
                .variants.first(where: { $0.name == "default" })?
                            .destinationProperty, storeDestinationAppStore)
            
            XCTAssertEqual(configuration.ios?
                .variants.first(where: { $0.name == "BETA" })?
                            .destinationProperty, storeDestinationAppCenter)
            
        } catch {
            XCTAssertTrue(((error as? DecodingError) == nil))
        }
    }
    
    func testStoreDestination_android() {
        let storeDestinationAppCenter = CustomProperty(
            name: "STORE_DESTINATION",
            value: AndroidVariant.Destination.appCenter.rawValue,
            destination: .fastlane
        )
        
        let storeDestinationPlayStore = CustomProperty(
            name: "STORE_DESTINATION",
            value: AndroidVariant.Destination.playStore.rawValue,
            destination: .fastlane
        )
        
        let parser = YamlParser()
        do {
            guard let path = Bundle(for: type(of: self)).path(forResource: "Resources/valid_variants", ofType: "yml") else { return }
            let configuration = try parser.extractConfiguration(from: path, platform: .ios)
            
            XCTAssertEqual(configuration.android?
                .variants.first(where: { $0.name == "default" })?
                            .destinationProperty, storeDestinationPlayStore)
            
            XCTAssertEqual(configuration.android?
                .variants.first(where: { $0.name == "test" })?
                            .destinationProperty, storeDestinationAppCenter)
            
        } catch {
            XCTAssertTrue(((error as? DecodingError) == nil))
        }
    }
    
    static var allTests = [
        ("testExtractConfiguration_invalidSpec", testExtractConfiguration_invalidSpec),
        ("testExtractConfiguration_valid_iOS", testExtractConfiguration_valid_iOS),
        ("testExtractConfiguration_valid_android", testExtractConfiguration_valid_android),
        ("testStoreDestination_iOS", testStoreDestination_iOS)
    ]
}
