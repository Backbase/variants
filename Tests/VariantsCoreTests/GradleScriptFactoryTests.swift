//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import XCTest
import PathKit
@testable import VariantsCore

class GradleScriptFactoryTests: XCTestCase {
    let correctOutput =
        """
        // ==== Variant values ====
        rootProject.ext.versionName = "1.1.3"
        rootProject.ext.versionCode = 101
        rootProject.ext.appIdentifier = "com.test.testapp.test"
        rootProject.ext.appName = "TestApp Test"
        // ==== Wrapper gradle tasks ====
        def vBuild = task vBuild
        def vUnitTests = task vUnitTests
        def vUITests = task vUITests
        tasks.whenTaskAdded { task ->
            if (task.name == "bundleProdRelease") {
                vBuild.dependsOn(task)
            } else if (task.name == "testProdReleaseUnitTest") {
                vUnitTests.dependsOn(task)
            } else if (task.name == "connectedProdReleaseAndroidTest") {
                vUITests.dependsOn(task)
            }
        }
        """

    let androidConfiguration = AndroidConfiguration(
        path: "projectPath",
        appName: "TestApp",
        appIdentifier: "com.test.testapp",
        variants: [
            AndroidVariant(
                name: "default",
                versionName: "1.1.0",
                versionCode: "99",
                idSuffix: nil,
                taskBuild: "bundleProdRelease",
                taskUnitTest: "testProdReleaseUnitTest",
                taskUitest: "connectedProdReleaseAndroidTest",
                custom: [],
                store_destination: nil
            ),
            AndroidVariant(
                name: "Test",
                versionName: "1.1.3",
                versionCode: "101",
                idSuffix: "test",
                taskBuild: "bundleProdRelease",
                taskUnitTest: "testProdReleaseUnitTest",
                taskUitest: "connectedProdReleaseAndroidTest",
                custom: [],
                store_destination: nil
            )
        ],
        signing: nil,
        custom: []
    )
    
    func testRender_correctData() {
        guard
            let templateFilePath = Bundle(for: type(of: self))
                .path(forResource: "Resources/android/variants-template", ofType: "gradle"),
            let templateFileContent = try? String(contentsOfFile: templateFilePath,
                                                  encoding: .utf8)
        else { return }
        
        // Assset we are able to write the template's content to a temporary
        // template in `private/tmp/`, to be used as `Path` from this test target.
        // Without this Path, `FastlaneParametersFactory` can't be tested as it
        // depends on `Stencil.FileSystemLoader` to load the template.
        let androidFolder = Path("./android/")
        if androidFolder.exists {
            XCTAssertNoThrow(try androidFolder.delete())
        }
        XCTAssertNoThrow(try androidFolder.mkpath())
        let temporaryTemplatePath = Path("./android/variants-template.gradle")
        XCTAssertNoThrow(try temporaryTemplatePath.write(templateFileContent))
        
        let factory = GradleScriptFactory(templatePath: Path("./"))
        guard let variant = androidConfiguration.variants.first(where: { $0.name == "Test" })
        else { return }
        XCTAssertNoThrow(try factory.render(with: androidConfiguration, variant: variant))
        XCTAssertNotNil(try factory.render(with: androidConfiguration, variant: variant))
        
        do {
            if let renderedData = try factory.render(with: androidConfiguration, variant: variant) {
                XCTAssertEqual(String(data: renderedData, encoding: .utf8), correctOutput)
            }
        } catch {
            XCTFail("'Try' should not throw - "+error.localizedDescription)
        }
    }
    
    func testFileWrite_correctOutput() {
        do {
            let variantsScriptPath = try Path(androidConfiguration.path).safeJoin(path: Path("gradleScripts/"))
            if !variantsScriptPath.exists {
                try variantsScriptPath.mkpath()
            }
            let factory = GradleScriptFactory(templatePath: Path("./"))
            XCTAssertNoThrow(try factory.write(Data(correctOutput.utf8), using: variantsScriptPath))
            
            let variantsScriptFile = Path(variantsScriptPath.string+"/variants.gradle")
            XCTAssertTrue(variantsScriptFile.exists)
            XCTAssertEqual(try variantsScriptFile.read(), correctOutput)
        } catch {
            XCTFail("'Try' should not throw - "+error.localizedDescription)
        }
    }
}
