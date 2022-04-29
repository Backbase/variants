//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Abdoelrhman Eaita on 24/09/2021.
//

import XCTest
import PathKit

@testable import VariantsCore

class XcodeProjFactoryTests: XCTestCase {
    let xcodeProjectPath = Path("./Test.xcodeproj")
    
    override func setUp() async throws {
        if !xcodeProjectPath.exists {
            try xcodeProjectPath.mkpath()
        }
    }
    
    func testProjectPath() {
        let sut = XcodeProjFactory()
        XCTAssertEqual(sut.projectPath(), "Test.xcodeproj/")
    }
    
    func testWriteJson() {
        let proj = XCConfigFactory(logLevel: true)
        let file = Path("./output.json")
        let (success, path) = proj.writeJSON("{}", toFile: file)
        XCTAssertTrue(success)
        XCTAssertNotNil(path)
    }
    
    func testCreateConfiguration() {
        let proj = XCConfigFactory(logLevel: true)
        let target = iOSTarget(name: "", app_icon: "", bundleId: "", testTarget: "",
                               source: .init(path: "", info: "", config: ""))
        let variant = iOSVariant(name: target.name, app_icon: nil, id_suffix: nil,
                                 version_name: "", version_number: 0, signing: nil,
                                 custom: nil, store_destination: nil)
        XCTAssertNoThrow(try proj.createConfig(
            with: ("", target),
            variant: variant,
            xcodeProj: xcodeProjectPath.description,
            configPath: Path(""),
            addToXcodeProj: false
        ))
    }
    
    func testApplicationData() {
        let sut = XcodeProjFactory()
        XCTAssertEqual(sut.applicationData(), [VariantsCore.iOSProjectKey.project: "Test"])
    }
}
