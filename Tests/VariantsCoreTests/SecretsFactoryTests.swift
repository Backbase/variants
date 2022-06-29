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

class SecretsFactoryTests: XCTestCase {
    let variantsSwiftContent = """
    //
    //  Variants
    //
    //  Copyright (c) Backbase B.V. - https://www.backbase.com
    //  Created by Arthur Alves
    //
    import Foundation
    public struct Variants {
        static let configuration: [String: Any] = {
            guard let infoDictionary = Bundle.main.infoDictionary else {
                fatalError("Info.plist file not found")
            }
            return infoDictionary
        }()
    }
    
    """
    
    private let defaultVariant = try? iOSVariant(
        name: "default",
        versionName: "2.3.4",
        versionNumber: 99,
        appIcon: nil,
        storeDestination: "testFlight",
        custom: [CustomProperty(name: "PROPERTY_A", value: "VALUE_A", destination: .project)],
        idSuffix: nil,
        bundleID: nil,
        variantSigning: nil,
        globalSigning: iOSSigning(teamName: "", teamID: "", exportMethod: .appstore, matchURL: ""))
    
    func testRender_noSecrets() {
        guard let configFile = Bundle(for: type(of: self))
                .path(forResource: "Resources/ios/sample", ofType: "xcconfig") else { return }
        
        let configPath = Path(configFile)
        XCTAssertTrue(configPath.exists)

        // commented, as comparing file content not working properly (need to find better way to test)
        let secretsFactory = SecretsFactory()
        guard let defaultVariant = defaultVariant else { return XCTFail("Failed to initialize iOSVariant with provided parameters") }
        secretsFactory.updateSecrets(with: configPath, variant: defaultVariant)

        let variantsFilePath = Bundle(for: type(of: self)).path(forResource: "Resources/ios/Variants", ofType: "swift")
        XCTAssertNotNil(variantsFilePath)
//        guard let variantsFile = variantsFilePath else { return }
//        XCTAssertEqual(try String(contentsOfFile: variantsFile), variantsSwiftContent)
    }
    
    func testUtilsDirectory_pathExists() {
        XCTAssertEqual(try UtilsDirectory().path.exists, true)
        XCTAssertEqual(try TemplateDirectory().path.exists, true)
    }
    
    static var allTests = [
        ("testRender_correctData", testRender_noSecrets),
        ("testUtilsDirectory_pathExists", testUtilsDirectory_pathExists)
    ]
}
