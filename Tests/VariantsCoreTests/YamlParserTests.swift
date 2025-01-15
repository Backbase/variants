//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

// swiftlint:disable file_length

import XCTest
@testable import VariantsCore

class YamlParserTests: XCTestCase {
    
    func testExtractConfiguration_invalidSpec() {
        let parser = YamlParser()
        do {
            guard let path = Bundle(for: type(of: self))
                    .path(forResource: "Resources/invalid_variants", ofType: "yml") else { return }
            _ = try parser.extractConfiguration(from: path, platform: .ios)
        } catch {
            XCTAssertTrue(((error as? DecodingError) != nil))
        }
    }
    
    func testExtractConfiguration_invalid_iOS_missingExportMethod() {
        let expectedUnderlyingError = RuntimeError(
            """
            Missing: 'signing.export_method'
            At least one variant doesn't contain 'signing.export_method' in its configuration.
            Create a global 'signing' configuration with 'export_method' or make sure all variants have this property.
            """
        )
        
        let parser = YamlParser()
        guard let path = Bundle(for: type(of: self))
                .path(forResource: "Resources/ios/invalid_missing_export_method", ofType: "yml") else { return }
        XCTAssertThrowsError(try parser.extractConfiguration(from: path, platform: .ios),
                             "No export method found globally or in variant BETA") { (error) in
            
            XCTAssertNotNil(error as? Swift.DecodingError)
            switch error as? Swift.DecodingError {
            case .dataCorrupted(let context):
                XCTAssertEqual(context.debugDescription, "The given data was not valid YAML.")
                XCTAssertNotNil(context.underlyingError as? RuntimeError)
                XCTAssertEqual(context.underlyingError as? RuntimeError, expectedUnderlyingError)
            default: break
            }
        }
    }
    
    func testExtractConfiguration_invalid_iOS_incompleteSigningConfiguration() {
        let expectedUnderlyingError = RuntimeError(
            """
            Missing: 'signing.export_method'
            At least one variant doesn't contain 'signing.export_method' in its configuration.
            Create a global 'signing' configuration with 'export_method' or make sure all variants have this property.
            """
        )
        
        let parser = YamlParser()
        guard let path = Bundle(for: type(of: self))
                .path(forResource: "Resources/ios/invalid_missing_signing_configuration", ofType: "yml") else { return }
        XCTAssertThrowsError(try parser.extractConfiguration(from: path, platform: .ios),
                             "No signing configuration found globally or in variant BETA") { (error) in
            
            XCTAssertNotNil(error as? Swift.DecodingError)
            switch error as? Swift.DecodingError {
            case .dataCorrupted(let context):
                XCTAssertEqual(context.debugDescription, "The given data was not valid YAML.")
                XCTAssertNotNil(context.underlyingError as? RuntimeError)
                XCTAssertEqual(context.underlyingError as? RuntimeError, expectedUnderlyingError)
            default: break
            }
        }
    }

    // swiftlint:disable:next function_body_length
    func testExtractConfiguration_valid_iOS() {
        let parser = YamlParser()
        do {
            guard let path = Bundle(for: type(of: self))
                    .path(forResource: "Resources/valid_variants", ofType: "yml") else { return }
            let configuration = try parser.extractConfiguration(from: path, platform: .ios)
            
            // MARK: - iOS Target Information
            
            XCTAssertNotNil(configuration.ios)
            if let iosConfiguration = configuration.ios {
                XCTAssertEqual(iosConfiguration.targets.count, 1)
                XCTAssertEqual(iosConfiguration.targets.first?.value.name, "FrankBank")
                XCTAssertEqual(iosConfiguration.targets.first?.value.bundleId, "com.backbase.frank.ios")
                XCTAssertEqual(iosConfiguration.variants.count, 3)
                XCTAssertTrue(iosConfiguration.variants.map(\.name).contains("default"))
                XCTAssertTrue(iosConfiguration.variants.map(\.name).contains("BETA"))
                XCTAssertTrue(iosConfiguration.variants.map(\.name).contains("STG"))
                XCTAssertEqual(iosConfiguration.xcodeproj, "FrankBank.xcodeproj")
                XCTAssertEqual(iosConfiguration.pbxproj, "FrankBank.xcodeproj/project.pbxproj")
            }
            
            let source = iOSSource(path: "sourcePath", info: "sourceInfo", config: "sourceConfig")
            let firstVariant = configuration.ios?.variants.first(where: { $0.name == "default" })
            XCTAssertNotNil(firstVariant)
            let firstVariantDefaultValues = firstVariant?.getDefaultValues(for:
                    iOSTarget(name: "FrankBank", app_icon: "AppIcon", bundleId: "com.backbase.frank.ios",
                              testTarget: "FrankBankTests", source: source)
            )
            XCTAssertEqual(firstVariantDefaultValues?.count, 7)
            XCTAssertEqual(firstVariantDefaultValues?[0].key, "SAMPLE_CONFIG")
            XCTAssertEqual(firstVariantDefaultValues?[0].value, "Production Value")
            XCTAssertEqual(firstVariantDefaultValues?[1].key, "V_APP_ICON")
            XCTAssertEqual(firstVariantDefaultValues?[1].value, "AppIcon")
            XCTAssertEqual(firstVariantDefaultValues?[2].key, "V_APP_NAME")
            XCTAssertEqual(firstVariantDefaultValues?[2].value, "FrankBank")
            XCTAssertEqual(firstVariantDefaultValues?[3].key, "V_BUNDLE_ID")
            XCTAssertEqual(firstVariantDefaultValues?[3].value, "com.backbase.frank.ios")
            XCTAssertEqual(firstVariantDefaultValues?[4].key, "V_MATCH_PROFILE")
            XCTAssertEqual(firstVariantDefaultValues?[4].value, "match AppStore com.backbase.frank.ios")
            XCTAssertEqual(firstVariantDefaultValues?[5].key, "V_VERSION_NAME")
            XCTAssertEqual(firstVariantDefaultValues?[5].value, "0.0.1")
            XCTAssertEqual(firstVariantDefaultValues?[6].key, "V_VERSION_NUMBER")
            XCTAssertEqual(firstVariantDefaultValues?[6].value, "1")
            
            // MARK: - iOS Global Properties
            
            let customGlobalConfig = configuration.ios?
                .custom?.first(where: { $0.name == "SAMPLE_GLOBAL" })
            XCTAssertNotNil(customGlobalConfig)
            assertCustom(customGlobalConfig!, value: "GLOBAL Value iOS", destination: .project)
                
            // MARK: - iOS Custom Properties
                        
            let customConfigBeta = configuration.ios?
                .variants.first(where: { $0.name == "BETA" })?
                .custom?.first(where: { $0.name == "SAMPLE_CONFIG" })
            XCTAssertNotNil(customConfigBeta)
            assertCustom(customConfigBeta!, value: "BETA Value", destination: .fastlane)
                        
            // MARK: - iOS Signing Configuration
            
            let defaultMatchConfiguration = firstVariant?.signing
            XCTAssertNotNil(defaultMatchConfiguration)
            XCTAssertEqual(defaultMatchConfiguration?.teamName, "BACKBASE EUROPE B.V.")
            XCTAssertEqual(defaultMatchConfiguration?.teamID, "AB123456CD")
            XCTAssertEqual(defaultMatchConfiguration?.matchURL, "git@github.com:sample/match.git")
            XCTAssertEqual(defaultMatchConfiguration?.exportMethod, .appstore)
            
            let betaMatchConfiguration = configuration.ios?
                .variants.first(where: { $0.name == "BETA" })?
                .signing
            XCTAssertNotNil(betaMatchConfiguration)
            XCTAssertEqual(betaMatchConfiguration?.teamName, "iPhone Distribution: BACKBASE EUROPE B.V.")
            XCTAssertEqual(betaMatchConfiguration?.teamID, "AB123456CD")
            XCTAssertNil(betaMatchConfiguration?.matchURL)
            XCTAssertEqual(betaMatchConfiguration?.exportMethod, .enterprise)
            
            let stagingMatchConfiguration = configuration.ios?
                .variants.first(where: { $0.name == "STG" })?
                .signing
            XCTAssertNotNil(stagingMatchConfiguration)
            XCTAssertEqual(stagingMatchConfiguration?.teamName, "iPhone Distribution: BACKBASE EUROPE B.V.")
            XCTAssertEqual(stagingMatchConfiguration?.teamID, "AB123456CD")
            XCTAssertEqual(stagingMatchConfiguration?.matchURL, "git@github.com:sample/enterprise-match.git")
            XCTAssertEqual(stagingMatchConfiguration?.exportMethod, .enterprise)
            
        } catch {
            dump(error)
            XCTAssertTrue(((error as? DecodingError) == nil))
        }
    }

    func testExtractConfiguration_valid_android() {
        let parser = YamlParser()
        do {
            guard let path = Bundle(for: type(of: self))
                    .path(forResource: "Resources/valid_variants", ofType: "yml") else { return }
            let configuration = try parser.extractConfiguration(from: path, platform: .android)
            
            XCTAssertNotNil(configuration.android)
            XCTAssertEqual(configuration.android?.appName, "FrankBank")
            XCTAssertEqual(configuration.android?.appIdentifier, "com.backbase.frank")
            XCTAssertEqual(configuration.android?.path, ".")
            XCTAssertEqual(configuration.android?.variants.count, 2)
            XCTAssertTrue(((configuration.android?.variants.map(\.name).contains("default")) != nil))
            XCTAssertTrue(((configuration.android?.variants.map(\.name).contains("test")) != nil))
            
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
            guard let path = Bundle(for: type(of: self))
                    .path(forResource: "Resources/valid_variants", ofType: "yml") else { return }
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
            guard let path = Bundle(for: type(of: self))
                    .path(forResource: "Resources/valid_variants", ofType: "yml") else { return }
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

    fileprivate func assertCustom(_ custom: CustomProperty, value: String, destination: CustomProperty.Destination) {
        XCTAssertEqual(custom.value, value)
        XCTAssertEqual(custom.destination, destination)
    }
    
    static var allTests = [
        ("testExtractConfiguration_invalidSpec",
         testExtractConfiguration_invalidSpec),
        ("testExtractConfiguration_invalid_iOS_missingExportMethod",
         testExtractConfiguration_invalid_iOS_missingExportMethod),
        ("testExtractConfiguration_invalid_iOS_incompleteSigningConfiguration",
         testExtractConfiguration_invalid_iOS_incompleteSigningConfiguration),
        ("testExtractConfiguration_valid_iOS",
         testExtractConfiguration_valid_iOS),
        ("testExtractConfiguration_valid_android",
         testExtractConfiguration_valid_android),
        ("testStoreDestination_iOS",
         testStoreDestination_iOS)
    ]
}

// swiftlint:enable file_length
