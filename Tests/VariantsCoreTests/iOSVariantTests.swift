//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Gabriel Rodrigues Minucci
//

// swiftlint:disable type_body_length
// swiftlint:disable file_length
// swiftlint:disable line_length
// swiftlint:disable type_name

import XCTest
@testable import VariantsCore

class iOSVariantTests: XCTestCase {
    private let validSigning = iOSSigning(teamName: "Signing Team Name", teamID: "AB12345CD", exportMethod: .appstore, matchURL: "git@github.com:sample/match.git")
    private let target = iOSTarget(name: "Target Name", app_icon: "AppIcon", bundleId: "com.Company.ValidName", testTarget: "ValidNameTests", source: iOSSource(path: "", info: "", config: ""))
    
    // MARK: - Initializer tests
    func testiOSVariantInitWithUnnamediOSVariant() {
        let customProperties = [CustomProperty(name: "Name", value: "Value", destination: .project)]
        let unnamedVariant = UnnamediOSVariant(versionName: "1.0", versionNumber: 0, appIcon: "app_icon", idSuffix: "beta", bundleID: nil,
                                               signing: validSigning, custom: customProperties, storeDestination: "testflight")
        
        func makeiOSVariant() throws -> iOSVariant {
            try iOSVariant(from: unnamedVariant, name: "beta", globalSigning: nil)
        }
        
        XCTAssertNoThrow(try makeiOSVariant())
        
        guard let variant = try? makeiOSVariant() else { return XCTFail("Failed to initialize iOSVariant with provided parameters") }
        XCTAssertEqual(variant.name, "beta")
        XCTAssertEqual(variant.versionName, unnamedVariant.versionName)
        XCTAssertEqual(variant.versionNumber, unnamedVariant.versionNumber)
        XCTAssertEqual(variant.appIcon, unnamedVariant.appIcon)
        XCTAssertEqual(variant.storeDestination, iOSVariant.Destination(rawValue: unnamedVariant.storeDestination!.lowercased())!)
        XCTAssertEqual(variant.custom, unnamedVariant.custom)
        XCTAssertEqual(variant.makeBundleID(for: target), "com.Company.ValidName.beta")
    }
    
    // MARK: - Default property assigning
    func testInitNilFallbackToDefaultProperties() {
        func makeiOSVariant() throws -> iOSVariant {
            try iOSVariant(name: "Valid Name", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: nil, custom: nil,
                           idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: validSigning)
        }
        
        XCTAssertNoThrow(try makeiOSVariant())
        
        let variant = try? makeiOSVariant()
        XCTAssertEqual(variant?.storeDestination, iOSVariant.Destination.appStore)
    }
    
    // MARK: - Computed properties
    func testGetTitle() {
        let name = "Variant Name"
        guard let variant = try? iOSVariant(name: name, versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore", custom: nil,
                                            idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: validSigning)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }
        XCTAssertEqual(variant.title, name)
    }
    
    func testGetConfigName() {
        // Default variant
        guard let defaultVariant = try? iOSVariant(name: "default", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore", custom: nil,
                                                   idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: validSigning)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }
        XCTAssertEqual(defaultVariant.configName, "")
        
        // Any variant
        let name = "Variant Name"
        guard let anyVariant = try? iOSVariant(name: name, versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore", custom: nil,
                                               idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: validSigning)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }
        XCTAssertEqual(anyVariant.configName, " \(name)")
    }
    
    func testGetDestinationProperty() {
        let targetDestination = iOSVariant.Destination.appCenter
        guard let variant = try? iOSVariant(name: "Valid Name", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: targetDestination.rawValue,
                                            custom: nil, idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: validSigning)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }
        
        let expectedResult = CustomProperty(name: "STORE_DESTINATION", value: targetDestination.rawValue, destination: .fastlane)
        let result = variant.destinationProperty
        XCTAssertEqual(result.name, expectedResult.name)
        XCTAssertEqual(result.value, expectedResult.value)
        XCTAssertEqual(result.destination, expectedResult.destination)
    }
        
    // MARK: - Bundle ID and ID Suffix tests
    
    func testInitiOSVariantWithIDSuffixOrBundleID() {
        // Only ID Suffix
        XCTAssertNoThrow(try iOSVariant(
            name: "Valid Name",
            versionName: "1.0.0",
            versionNumber: 0,
            appIcon: nil,
            storeDestination: "appStore",
            custom: nil,
            idSuffix: "beta",
            bundleID: nil,
            variantSigning: nil,
            globalSigning: validSigning))
        
        // Only Bundle ID
        XCTAssertNoThrow(try iOSVariant(
            name: "Valid Name",
            versionName: "1.0.0",
            versionNumber: 0,
            appIcon: nil,
            storeDestination: "appStore",
            custom: nil,
            idSuffix: nil,
            bundleID: "com.company.customBundle",
            variantSigning: nil,
            globalSigning: validSigning))
    }
    
    func testInitWithIDSuffixAndBundleID() {
        let expectedError = RuntimeError(
            """
            Variant "Valid Name" have "id_suffix" and "bundle_id" configured at the same time or no \
            configuration were provided to any of them. Please provide only one of them per variant.
            """
        )
        
        func makeiOSVariant() throws -> iOSVariant {
            try iOSVariant(name: "Valid Name", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore", custom: nil,
                           idSuffix: "beta", bundleID: "com.company.customBundle", variantSigning: nil, globalSigning: validSigning)
        }
        
        XCTAssertThrowsError(try makeiOSVariant(), "ID Suffix and Bundle ID can't be configured at same time in the same variant") { error in
            XCTAssertEqual(error as? RuntimeError, expectedError)
        }
    }
    
    func testInitWithoutIDSuffixOrBundleID() {
        let expectedError = RuntimeError(
            """
            Variant "Valid Name" have "id_suffix" and "bundle_id" configured at the same time or no \
            configuration were provided to any of them. Please provide only one of them per variant.
            """
        )
        
        func makeiOSVariant() throws -> iOSVariant {
            try iOSVariant(name: "Valid Name", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore", custom: nil,
                           idSuffix: nil, bundleID: nil, variantSigning: nil, globalSigning: validSigning)
        }
        
        XCTAssertThrowsError(try makeiOSVariant(), "ID Suffix and Bundle ID can't be configured at same time in the same variant") { error in
            XCTAssertEqual(error as? RuntimeError, expectedError)
        }
    }
    
    func testMakeBundleIDForVariant() {
        // ID Suffix provided
        guard let idSuffixVariant = try? iOSVariant(name: "Valid Name", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore", custom: nil,
                                                    idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: validSigning)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }
        XCTAssertEqual(idSuffixVariant.makeBundleID(for: target), "com.Company.ValidName.beta")
                
        // Bundle ID provided
        guard let bundleIDVariant = try? iOSVariant(name: "Valid Name", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore", custom: nil,
                                                    idSuffix: nil, bundleID: "com.Overwritten.BundleID", variantSigning: nil, globalSigning: validSigning)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }
        XCTAssertEqual(bundleIDVariant.makeBundleID(for: target), "com.Overwritten.BundleID")
        
        // Default variant
        guard let defaultVariant = try? iOSVariant(name: "default", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore", custom: nil,
                                                   idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: validSigning)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }
        XCTAssertEqual(defaultVariant.makeBundleID(for: target), "com.Company.ValidName")
    }
        
    // MARK: - Signing tests
    
    func testInitWithValidSigningConfiguration() {
        // Variant and Global signing defined
        XCTAssertNoThrow(try iOSVariant(
            name: "Valid Name",
            versionName: "1.0.0",
            versionNumber: 0,
            appIcon: nil,
            storeDestination: "appStore",
            custom: nil,
            idSuffix: "beta",
            bundleID: nil,
            variantSigning: validSigning,
            globalSigning: validSigning))
        
        // Only variant signing defined
        XCTAssertNoThrow(try iOSVariant(
            name: "Valid Name",
            versionName: "1.0.0",
            versionNumber: 0,
            appIcon: nil,
            storeDestination: "appStore",
            custom: nil,
            idSuffix: "beta",
            bundleID: nil,
            variantSigning: validSigning,
            globalSigning: nil))
        
        // Only global signing defined
        XCTAssertNoThrow(try iOSVariant(
            name: "Valid Name",
            versionName: "1.0.0",
            versionNumber: 0,
            appIcon: nil,
            storeDestination: "appStore",
            custom: nil,
            idSuffix: "beta",
            bundleID: nil,
            variantSigning: nil,
            globalSigning: validSigning))
    }
    
    func testInitWithoutSigningConfiguration() {
        func makeiOSVariant() throws -> iOSVariant {
            try iOSVariant(name: "Valid Name", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore", custom: nil,
                           idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: nil)
        }

        XCTAssertNoThrow(try makeiOSVariant())
    }
    
    func testGetDefaultValuesForTargetWithoutSigning() {
        let expectedValues: [(key: String, value: String)] = [
            (key: "V_APP_ICON", value: "AppIcon"),
            (key: "V_APP_NAME", value: "Target Name Beta"),
            (key: "V_BUNDLE_ID", value: "com.Company.ValidName.beta"),
            (key: "V_VERSION_NAME", value: "1.0.0"),
            (key: "V_VERSION_NUMBER", value: "0")
        ]
        let signing = iOSSigning(teamName: "Signing Team Name", teamID: "AB12345CD", exportMethod: .appstore, matchURL: nil)
        guard let variant = try? iOSVariant(name: "Beta", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore", custom: nil,
                                            idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: signing)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }
        let defaultValues = variant.getDefaultValues(for: target)
        XCTAssertEqual(defaultValues.count, expectedValues.count)
        defaultValues.enumerated().forEach({
            XCTAssertEqual($1.key, expectedValues[$0].key)
        })
    }
    
    func testGetDefaultValuesForTargetWithSigning() {
        let expectedValues = [
            (key: "V_APP_ICON", value: "AppIcon"),
            (key: "V_APP_NAME", value: "Target Name Beta"),
            (key: "V_BUNDLE_ID", value: "com.Company.ValidName.beta"),
            (key: "V_MATCH_PROFILE", value: "match AppStore com.Company.ValidName.beta"),
            (key: "V_VERSION_NAME", value: "1.0.0"),
            (key: "V_VERSION_NUMBER", value: "0")
        ]
        guard let variant = try? iOSVariant(name: "Beta", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore", custom: nil,
                                            idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: validSigning)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }

        let defaultValues = variant.getDefaultValues(for: target)
        XCTAssertEqual(defaultValues.count, expectedValues.count)
        defaultValues.enumerated().forEach({
            XCTAssertEqual($1.key, expectedValues[$0].key)
        })
    }
    
    func testGetDefaultValuesWithTargetAndCustomProperties() {
        let expectedValues = [
            (key: "Custom name", value: "Custom value"),
            (key: "V_APP_ICON", value: "AppIcon"),
            (key: "V_APP_NAME", value: "Target Name Beta"),
            (key: "V_BUNDLE_ID", value: "com.Company.ValidName.beta"),
            (key: "V_MATCH_PROFILE", value: "match AppStore com.Company.ValidName.beta"),
            (key: "V_VERSION_NAME", value: "1.0.0"),
            (key: "V_VERSION_NUMBER", value: "0")
        ]
        let customProperties = [
            CustomProperty(name: "Custom name", value: "Custom value", env: false, destination: .project),
            CustomProperty(name: "Custom name 2", value: "Custom value 2", env: true, destination: .project),
            CustomProperty(name: "Custom name 3", value: "Custom value 3", env: false, destination: .fastlane)]
        guard let variant = try? iOSVariant(name: "Beta", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: "appStore",
                                            custom: customProperties, idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: validSigning)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }

        let defaultValues = variant.getDefaultValues(for: target)
        XCTAssertEqual(defaultValues.count, expectedValues.count)
        defaultValues.enumerated().forEach({
            XCTAssertEqual($1.key, expectedValues[$0].key)
        })
        XCTAssertFalse(defaultValues.contains(where: {$0.key == "Custom name 2"}), "Should not contains this property as it's an environment variable")
        XCTAssertFalse(defaultValues.contains(where: {$0.key == "Custom name 3"}), "Should not contains this property as it's not a project destination property")
    }
    
    // MARK: - iOSVariants.Destination tests
    func testParsingiOSVariantDestintation() {
        func makeVariant(destination: String?) throws -> iOSVariant {
            try iOSVariant(name: "Variant Name", versionName: "1.0.0", versionNumber: 0, appIcon: nil, storeDestination: destination,
                           custom: nil, idSuffix: "beta", bundleID: nil, variantSigning: nil, globalSigning: validSigning)
        }
        
        // Should not throw if valid destination is provided
        XCTAssertNoThrow(try makeVariant(destination: "appcenter"))
        XCTAssertNoThrow(try makeVariant(destination: "appstore"))
        XCTAssertNoThrow(try makeVariant(destination: "testflight"))
        
        // Should be case insensitive
        XCTAssertNoThrow(try makeVariant(destination: "aPpCeNtEr"))
        
        // Should read correct value from input
        
        XCTAssertEqual((try? makeVariant(destination: "appcenter"))?.storeDestination, iOSVariant.Destination.appCenter)
        XCTAssertEqual((try? makeVariant(destination: "appstore"))?.storeDestination, iOSVariant.Destination.appStore)
        XCTAssertEqual((try? makeVariant(destination: "testflight"))?.storeDestination, iOSVariant.Destination.testFlight)
        
        // Should throw an error with invalid option provided
        XCTAssertThrowsError(try makeVariant(destination: "notAValidOption"))
    }
                
    static var allTests = [
        ("testiOSVariantInitWithUnnamediOSVariant", testiOSVariantInitWithUnnamediOSVariant),
        ("testInitNilFallbackToDefaultProperties", testInitNilFallbackToDefaultProperties),
        ("testGetTitle", testGetTitle),
        ("testGetConfigName", testGetConfigName),
        ("testGetDestinationProperty", testGetDestinationProperty),
        ("testInitiOSVariantWithIDSuffixOrBundleID", testInitiOSVariantWithIDSuffixOrBundleID),
        ("testInitWithIDSuffixAndBundleID", testInitWithIDSuffixAndBundleID),
        ("testInitWithoutIDSuffixOrBundleID", testInitWithoutIDSuffixOrBundleID),
        ("testMakeBundleIDForVariant", testMakeBundleIDForVariant),
        ("testInitWithValidSigningConfiguration", testInitWithValidSigningConfiguration),
        ("testInitWithoutSigningConfiguration", testInitWithoutSigningConfiguration),
        ("testGetDefaultValuesForTargetWithoutSigning", testGetDefaultValuesForTargetWithoutSigning),
        ("testGetDefaultValuesForTargetWithSigning", testGetDefaultValuesForTargetWithSigning),
        ("testGetDefaultValuesWithTargetAndCustomProperties", testGetDefaultValuesWithTargetAndCustomProperties),
        ("testParsingiOSVariantDestintation", testParsingiOSVariantDestintation)
    ]
}

// swiftlint:enable type_body_length
// swiftlint:enable line_length
// swiftlint:enable type_name
