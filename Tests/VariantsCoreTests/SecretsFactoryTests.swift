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
    
    let defaultVariant = iOSVariant(
        name: "default",
        app_icon: nil,
        id_suffix: "",
        version_name: "2.3.4",
        version_number: 99,
        signing: nil,
        custom: [
            CustomProperty(name: "PROPERTY_A",
                           value: "VALUE_A",
                           destination: .project)
        ],
        store_destination: "TestFlight"
    )
    
    func testRender_noSecrets() {
        guard let configFile = Bundle(for: type(of: self))
                .path(forResource: "Resources/ios/sample", ofType: "xcconfig") else { return }
        
        let configPath = Path(configFile)
        XCTAssertTrue(configPath.exists)
        
        let secretsFactory = SecretsFactory()
        secretsFactory.updateSecrets(with: configPath, variant: defaultVariant)
        
        let variantsFilePath = Bundle(for: type(of: self)).path(forResource: "Resources/ios/Variants", ofType: "swift")
        XCTAssertNotNil(variantsFilePath)
        guard let variantsFile = variantsFilePath else { return }
        XCTAssertEqual(try String(contentsOfFile: variantsFile), variantsSwiftContent)
    }
    
    static var allTests = [
        ("testRender_correctData", testRender_noSecrets)
    ]
}
