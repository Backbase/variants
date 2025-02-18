//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Gabriel Rodrigues Minucci on 27/01/2025.
//

// swiftlint:disable line_length
// swiftlint:disable type_name

import XCTest
@testable import VariantsCore

class iOSTargetExtensionTests: XCTestCase {
    private let validSigning = iOSSigning(teamName: "Signing Team Name", teamID: "AB12345CD", exportMethod: .appstore, matchURL: "git@github.com:sample/match.git", style: .manual, autoDetectSigningIdentity: true)
    private let target = iOSTarget(name: "Target Name", app_icon: "AppIcon", bundleId: "com.Company.ValidName", testTarget: "ValidNameTests", source: iOSSource(path: "", info: "", config: ""))

    func testTargetExtensionCreationWithBundleSuffix() {
        guard let variant = try? iOSVariant(
            name: name, versionName: "1.0.0", versionNumber: 0, appIcon: nil, appName: nil, storeDestination: "appStore",
            idSuffix: "beta", bundleID: nil, globalCustomProperties: nil, variantCustomProperties: nil,
            globalSigning: validSigning, debugSigning: nil, releaseSigning: nil, globalPostSwitchScript: nil, variantPostSwitchScript: nil)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }
        
        let extensionsJsonString = """
        {"name": "TestExtension", "bundle_suffix": "TestExtension", "signed": true}
        """
        guard let targetExtension = try? JSONDecoder().decode(iOSExtension.self, from: Data(extensionsJsonString.utf8))
        else { return XCTFail("Failed to decode JSON for extensions data") }

        XCTAssertEqual(targetExtension.name, "TestExtension")
        XCTAssertEqual(targetExtension.signed, true)
        XCTAssertEqual(targetExtension.bundleNamingOption, .suffix("TestExtension"))

        let generatedBundleForTarget = targetExtension.makeBundleID(variant: variant, target: target)
        XCTAssertEqual(generatedBundleForTarget, "com.Company.ValidName.beta.TestExtension")
    }

    func testTargetExtensionCreationWithBundleID() {
        guard let variant = try? iOSVariant(
            name: name, versionName: "1.0.0", versionNumber: 0, appIcon: nil, appName: nil, storeDestination: "appStore",
            idSuffix: "beta", bundleID: nil, globalCustomProperties: nil, variantCustomProperties: nil,
            globalSigning: validSigning, debugSigning: nil, releaseSigning: nil, globalPostSwitchScript: nil, variantPostSwitchScript: nil)
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }

        let extensionsJsonString = """
        {"name": "TestExtension", "bundle_id": "com.test.App.TestExtension", "signed": true}
        """

        guard let targetExtension = try? JSONDecoder().decode(iOSExtension.self, from: Data(extensionsJsonString.utf8))
        else { return XCTFail("Failed to decode JSON for extensions data") }

        XCTAssertEqual(targetExtension.name, "TestExtension")
        XCTAssertEqual(targetExtension.signed, true)
        XCTAssertEqual(targetExtension.bundleNamingOption, .explicit("com.test.App.TestExtension"))

        let generatedBundleForTarget = targetExtension.makeBundleID(variant: variant, target: target)
        XCTAssertEqual(generatedBundleForTarget, "com.test.App.TestExtension")
    }

    func testTargetExtensionCreationWithBundleIDAndBundleSuffix() {
        let extensionsJsonString = """
        {"name": "TestExtension", "bundle_suffix": "TestExtension", "bundle_id": "com.test.App.TestExtension", "signed": true}
        """

        XCTAssertThrowsError(try JSONDecoder().decode(iOSExtension.self, from: Data(extensionsJsonString.utf8)))
    }

    static var allTests = [
        ("testTargetExtensionCreationWithBundleSuffix", testTargetExtensionCreationWithBundleSuffix),
        ("testTargetExtensionCreationWithBundleID", testTargetExtensionCreationWithBundleID),
        ("testTargetExtensionCreationWithBundleIDAndBundleSuffix", testTargetExtensionCreationWithBundleIDAndBundleSuffix)
    ]
}

// swiftlint:enable line_length
// swiftlint:enable type_name
