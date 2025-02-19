//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Roman Huti
//

// swiftlint:disable type_name
// swiftlint:disable line_length

import XCTest
@testable import VariantsCore

final class iOSSigningTests: XCTestCase {
    
    private func makeUnnamedVariant(signing: iOSSigning?, debugSigning: iOSSigning?, releaseSigning: iOSSigning?) -> UnnamediOSVariant {
        return UnnamediOSVariant(
            versionName: "1", versionNumber: 1, appIcon: nil, appName: "AppName", idSuffix: "test", bundleID: nil,
            signing: signing, debugSigning: debugSigning, releaseSigning: releaseSigning, 
            custom: nil, storeDestination: "appstore", postSwitchScript: nil)
    }

    func testMergeValidSignings() throws {
        let signing = iOSSigning(teamName: "team",
                                 teamID: nil,
                                 exportMethod: .appstore,
                                 matchURL: "url",
                                 style: .manual,
                                 autoDetectSigningIdentity: true)
        let signing1 = iOSSigning(teamName: nil,
                                  teamID: "new id",
                                  exportMethod: .development,
                                  matchURL: nil,
                                  style: .manual,
                                  autoDetectSigningIdentity: true)

        do {
            let result = try signing ~ signing1
            XCTAssertEqual(result.teamName, "team")
            XCTAssertEqual(result.teamID, "new id")
            XCTAssertEqual(result.exportMethod, .appstore)
            XCTAssertEqual(result.matchURL, "url")
        } catch {
            XCTFail("Should not throw exception")
        }
    }
    
    func testMergeSigningsNoTeamName() throws {
        let signing = iOSSigning(teamName: nil,
                                 teamID: nil,
                                 exportMethod: .appstore,
                                 matchURL: "url",
                                 style: .manual,
                                 autoDetectSigningIdentity: true)
        let signing1 = iOSSigning(teamName: nil,
                                  teamID: "new id",
                                  exportMethod: .development,
                                  matchURL: "new url",
                                  style: .manual,
                                  autoDetectSigningIdentity: true)
        let expectedError = RuntimeError("""
            Missing: 'signing.team_name'
            At least one variant doesn't contain 'signing.team_name' in its configuration.
            Create a global 'signing' configuration with 'team_name' or make sure all variants have this property.
            """)
        
        do {
            _ = try signing ~ signing1
        } catch let error as RuntimeError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testMergeSigningsNoTeamId() throws {
        let signing = iOSSigning(teamName: nil,
                                 teamID: nil,
                                 exportMethod: .appstore,
                                 matchURL: "url",
                                 style: .manual,
                                 autoDetectSigningIdentity: true)
        let signing1 = iOSSigning(teamName: "Name",
                                  teamID: nil,
                                  exportMethod: .development,
                                  matchURL: "new url",
                                  style: .manual,
                                  autoDetectSigningIdentity: true)
        let expectedError = RuntimeError("""
            Missing: 'signing.team_id'
            At least one variant doesn't contain 'signing.team_id' in its configuration.
            Create a global 'signing' configuration with 'team_id' or make sure all variants have this property.
            """)
        
        do {
            _ = try signing ~ signing1
        } catch let error as RuntimeError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testCustomProperties() {
        let signing = iOSSigning(teamName: "Name",
                                 teamID: nil,
                                 exportMethod: .enterprise,
                                 matchURL: "url",
                                 style: .manual,
                                 autoDetectSigningIdentity: true)

        let expected = [CustomProperty(name: "TEAMNAME", value: "NAME", destination: .fastlane),
                        CustomProperty(name: "EXPORTMETHOD", value: "match InHouse", destination: .fastlane),
                        CustomProperty(name: "MATCHURL", value: "url", destination: .fastlane)]
        
        XCTAssertEqual(signing.customProperties(), expected)
    }
    
    func testExportMethodPrefixes() {
        let dev: iOSSigning.ExportMethod = .development,
            appstore: iOSSigning.ExportMethod = .appstore,
            enterprise: iOSSigning.ExportMethod = .enterprise,
            adhoc: iOSSigning.ExportMethod = .adhoc
        XCTAssertEqual(dev.prefix, "match Development")
        XCTAssertEqual(appstore.prefix, "match AppStore")
        XCTAssertEqual(enterprise.prefix, "match InHouse")
        XCTAssertEqual(adhoc.prefix, "match AdHoc")
    }

    func testOnlyGlobalSigning() {
        let globalSigning = iOSSigning(teamName: "global team name", teamID: "global_team_id", exportMethod: .appstore, matchURL: "global match url", style: .manual, autoDetectSigningIdentity: true)
        let unnamedVariant = makeUnnamedVariant(signing: nil, debugSigning: nil, releaseSigning: nil)
        guard
            let variant = try? iOSVariant(from: unnamedVariant, name: "", globalCustomProperties: nil, globalSigning: globalSigning, globalPostSwitchScript: nil)
        else { return XCTFail("Failed to generate variants") }

        XCTAssertEqual(variant.debugSigning, globalSigning)
        XCTAssertEqual(variant.releaseSigning, globalSigning)
    }

    func testGlobalAndVariantSigning() {
        let globalSigning = iOSSigning(teamName: "global team name", teamID: "global_team_id", exportMethod: .appstore, matchURL: "global match url", style: .manual, autoDetectSigningIdentity: true)
        let variantSigning = iOSSigning(teamName: "variant team name", teamID: "variant_team_id", exportMethod: .appstore, matchURL: "variant match url", style: .manual, autoDetectSigningIdentity: false)
        let unnamedVariant = makeUnnamedVariant(signing: variantSigning, debugSigning: nil, releaseSigning: nil)
        guard
            let variant = try? iOSVariant(from: unnamedVariant, name: "", globalCustomProperties: nil, globalSigning: globalSigning, globalPostSwitchScript: nil)
        else { return XCTFail("Failed to generate variants") }

        XCTAssertEqual(variant.debugSigning, variantSigning)
        XCTAssertEqual(variant.releaseSigning, variantSigning)
    }

    func testGlobalAndVariantReleaseSigning() {
        let globalSigning = iOSSigning(teamName: "global team name", teamID: "global_team_id", exportMethod: .appstore, matchURL: "global match url", style: .manual, autoDetectSigningIdentity: true)
        let variantReleaseSigning = iOSSigning(teamName: "variant team name", teamID: "variant_team_id", exportMethod: .appstore, matchURL: "variant match url", style: .manual, autoDetectSigningIdentity: false)
        let unnamedVariant = makeUnnamedVariant(signing: nil, debugSigning: nil, releaseSigning: variantReleaseSigning)
        guard
            let variant = try? iOSVariant(from: unnamedVariant, name: "", globalCustomProperties: nil, globalSigning: globalSigning, globalPostSwitchScript: nil)
        else { return XCTFail("Failed to generate variants") }

        XCTAssertEqual(variant.debugSigning, globalSigning)
        XCTAssertEqual(variant.releaseSigning, variantReleaseSigning)
    }

    func testGlobalAndVariantDebugSigning() {
        let globalSigning = iOSSigning(teamName: "global team name", teamID: "global_team_id", exportMethod: .appstore, matchURL: "global match url", style: .manual, autoDetectSigningIdentity: true)
        let variantDebugSigning = iOSSigning(teamName: "variant team name", teamID: "variant_team_id", exportMethod: .appstore, matchURL: "variant match url", style: .manual, autoDetectSigningIdentity: false)
        let unnamedVariant = makeUnnamedVariant(signing: nil, debugSigning: variantDebugSigning, releaseSigning: nil)
        guard
            let variant = try? iOSVariant(from: unnamedVariant, name: "", globalCustomProperties: nil, globalSigning: globalSigning, globalPostSwitchScript: nil)
        else { return XCTFail("Failed to generate variants") }

        XCTAssertEqual(variant.debugSigning, variantDebugSigning)
        XCTAssertEqual(variant.releaseSigning, globalSigning)
    }

    func testGlobalAndVariantReleaseDebugSigning() {
        let globalSigning = iOSSigning(teamName: "global team name", teamID: "global_team_id", exportMethod: .appstore, matchURL: "global match url", style: .manual, autoDetectSigningIdentity: true)
        let variantDebugSigning = iOSSigning(teamName: "variant debug team name", teamID: "variant_debug_team_id",
                                             exportMethod: .appstore, matchURL: "variant match url", style: .manual, autoDetectSigningIdentity: true)
        let variantReleaseSigning = iOSSigning(teamName: "variant release team name", teamID: "variant_release_team_id",
                                               exportMethod: .appstore, matchURL: "variant match url", style: .manual, autoDetectSigningIdentity: false)
        let unnamedVariant = makeUnnamedVariant(signing: nil, debugSigning: variantDebugSigning, releaseSigning: variantReleaseSigning)
        guard
            let variant = try? iOSVariant(from: unnamedVariant, name: "", globalCustomProperties: nil, globalSigning: globalSigning, globalPostSwitchScript: nil)
        else { return XCTFail("Failed to generate variants") }

        XCTAssertEqual(variant.debugSigning, variantDebugSigning)
        XCTAssertEqual(variant.releaseSigning, variantReleaseSigning)
    }

    func testGlobalAndVariantSigningAndDebugSigning() {
        let globalSigning = iOSSigning(teamName: "global team name", teamID: "global_team_id", exportMethod: .appstore, matchURL: "global match url", style: .manual, autoDetectSigningIdentity: true)
        let variantSigning = iOSSigning(teamName: "variant team name", teamID: "variant_team_id", exportMethod: .appstore, matchURL: "variant match url", style: .manual, autoDetectSigningIdentity: true)
        let variantDebugSigning = iOSSigning(teamName: "variant debug team name", teamID: "variant_debug_team_id", exportMethod: .appstore, matchURL: "variant match url", style: .manual, autoDetectSigningIdentity: true)
        let unnamedVariant = makeUnnamedVariant(signing: variantSigning, debugSigning: variantDebugSigning, releaseSigning: nil)
        guard
            let variant = try? iOSVariant(from: unnamedVariant, name: "", globalCustomProperties: nil, globalSigning: globalSigning, globalPostSwitchScript: nil)
        else { return XCTFail("Failed to generate variants") }

        XCTAssertEqual(variant.debugSigning, variantDebugSigning)
        XCTAssertEqual(variant.releaseSigning, variantSigning)
    }
}

// swiftlint:enable type_name
// swiftlint:enable line_length
