//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Roman Huti
//

// swiftlint:disable type_name

import XCTest
@testable import VariantsCore

final class iOSSigningTests: XCTestCase {
    
    func testMergeValidSignings() throws {
        let signing = iOSSigning(teamName: "team",
                                 teamID: nil,
                                 exportMethod: .appstore,
                                 matchURL: "url",
                                 style: .manual)
        let signing1 = iOSSigning(teamName: nil,
                                  teamID: "new id",
                                  exportMethod: .development,
                                  matchURL: nil,
                                  style: .manual)

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
                                 style: .manual)
        let signing1 = iOSSigning(teamName: nil,
                                  teamID: "new id",
                                  exportMethod: .development,
                                  matchURL: "new url",
                                  style: .manual)
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
                                 style: .manual)
        let signing1 = iOSSigning(teamName: "Name",
                                  teamID: nil,
                                  exportMethod: .development,
                                  matchURL: "new url",
                                  style: .manual)
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
                                 style: .manual)

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

}

// swiftlint:enable type_name
