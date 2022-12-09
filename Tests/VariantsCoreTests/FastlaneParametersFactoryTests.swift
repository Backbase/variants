//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import XCTest
import PathKit
@testable import VariantsCore

private let parameters = [
    CustomProperty(name: "sample", value: "sample-value", destination: .project),
    CustomProperty(name: "sample-2", value: "sample-2-value", destination: .fastlane),
    CustomProperty(name: "sample-3", value: "sample-3-value", destination: .project),
    CustomProperty(name: "sample-4", value: "sample-4-value", destination: .fastlane),
    CustomProperty(name: "sample-5", value: "sample-5-value", destination: .fastlane),
    CustomProperty(name: "sample-env", value: "API_TOKEN", env: true, destination: .fastlane)
]

private let correctOutput =
    """
    # Generated by Variants
    VARIANTS_PARAMS = {
        sample-2: \"sample-2-value\",
        sample-4: \"sample-4-value\",
        sample-5: \"sample-5-value\",
        sample-env: ENV[\"API_TOKEN\"],
    }.freeze
    """

private let parametersCorrectOutput =
    """
    # Generated by Variants
    MATCH_PARAMS = {
      MATCH_KEYCHAIN_NAME: ENV['MATCH_KEYCHAIN_NAME'],
      MATCH_KEYCHAIN_PASSWORD: ENV['MATCH_KEYCHAIN_PASSWORD'],
      
      # This is needed if your Match repository is private
      MATCH_GIT_BASIC_AUTHORIZATION: ENV['MATCH_GIT_BASIC_AUTHORIZATION'],
      
      # Match repository password, used to decrypt files
      MATCH_PASSWORD: ENV['MATCH_PASSWORD'],
      
      # Signing properties coming from Variants YAML spec. Do not change manually
      sample-2: "sample-2-value",
      sample-4: "sample-4-value",
      sample-5: "sample-5-value",
    }.freeze
    """

class FastlaneParametersFactoryTests: XCTestCase {
    
    func testCreatParametersFile() throws {
        let factory = FastlaneParametersFactory()
        let file = StaticPath.Template.matchParametersFileName
        let path = StaticPath.Fastlane.matchParametersFile
        
        try factory.createParametersFile(in: path, renderTemplate: file, with: parameters)
        
        XCTAssertTrue(path.exists)
        let result: String = try path.read()
        
        XCTAssertEqual(result, parametersCorrectOutput)
    }
    
    func testRender_correctData() {
        guard
            let templateFilePath = Bundle(for: type(of: self))
                .path(forResource: "Resources/variants_params_template", ofType: "rb"),
            let templateFileContent = try? String(contentsOfFile: templateFilePath,
                                                  encoding: .utf8)
        else { return }
        
        // Assset we are able to write the template's content to a temporary
        // template in `private/tmp/`, to be used as `Path` from this test target.
        // Without this Path, `FastlaneParametersFactory` can't be tested as it
        // depends on `Stencil.FileSystemLoader` to load the template.
        let temporaryTemplatePath = Path("variants_params_template.rb")
        XCTAssertNoThrow(try temporaryTemplatePath.write(templateFileContent))
        
        let factory = FastlaneParametersFactory(templatePath: Path("./"))
        
        XCTAssertNoThrow(try factory.render(context: context(for: parameters),
                                            renderTemplate: StaticPath.Template.fastlaneParametersFileName))
        XCTAssertNotNil(try factory.render(context: context(for: parameters),
                                           renderTemplate: StaticPath.Template.fastlaneParametersFileName))
        
        do {
            if let renderedData = try factory.render(context: context(for: parameters),
                                                     renderTemplate: StaticPath.Template.fastlaneParametersFileName) {
                XCTAssertEqual(String(data: renderedData, encoding: .utf8), correctOutput)
            }
        } catch {
            XCTFail("'Try' should not throw - "+error.localizedDescription)
        }
    }
    
    func testFileWrite_correctOutput() {
        let factory = FastlaneParametersFactory()
        let file = StaticPath.Template.fastlaneParametersFileName
        let path = StaticPath.Fastlane.variantsParametersFile
        
        XCTAssertNoThrow(try path.delete())
        XCTAssertNoThrow(try factory.createParametersFile(in: path, renderTemplate: file, with: parameters))
        XCTAssertTrue(path.exists)
        XCTAssertTrue(path.isWritable)
        
        XCTAssertNoThrow(try factory.write(Data(correctOutput.utf8), using: path))
        XCTAssertEqual(try path.read(), correctOutput)
    }
    
    func testFileWrite_appendingStore() {
        let expectedOutput =
            """
            # Generated by Variants
            VARIANTS_PARAMS = {
                sample-2: \"sample-2-value\",
                sample-4: \"sample-4-value\",
                sample-5: \"sample-5-value\",
                STORE_DESTINATION: \"testflight\",
                sample-env: ENV[\"API_TOKEN\"],
            }.freeze
            """
        
        guard let variant = try? iOSVariant(
            name: "sample-variant",
            versionName: "2.3.4",
            versionNumber: 99,
            appIcon: nil,
            storeDestination: "testFlight",
            custom: nil,
            idSuffix: "sample",
            bundleID: nil,
            variantSigning: nil,
            globalSigning: iOSSigning(teamName: "", teamID: "", exportMethod: .appstore, matchURL: ""))
        else {
            return XCTFail("Failed to initialize iOSVariant with provided parameters")
        }
        
        guard
            let templateFilePath = Bundle(for: type(of: self))
                .path(forResource: "Resources/variants_params_template", ofType: "rb"),
            let templateFileContent = try? String(contentsOfFile: templateFilePath,
                                                  encoding: .utf8)
        else { return }
        
        // Assset we are able to write the template's content to a temporary
        // template in `private/tmp/`, to be used as `Path` from this test target.
        // Without this Path, `FastlaneParametersFactory` can't be tested as it
        // depends on `Stencil.FileSystemLoader` to load the template.
        let temporaryTemplatePath = Path("variants_params_template.rb")
        XCTAssertNoThrow(try temporaryTemplatePath.write(templateFileContent))
        
        var fastlaneParameters = parameters.filter({ $0.destination == .fastlane })
        fastlaneParameters.append(variant.destinationProperty)
        let factory = FastlaneParametersFactory(templatePath: Path("./"))
        
        XCTAssertNoThrow(try factory.render(context: context(for: fastlaneParameters),
                                            renderTemplate: StaticPath.Template.fastlaneParametersFileName))
        XCTAssertNotNil(try factory.render(context: context(for: fastlaneParameters),
                                           renderTemplate: StaticPath.Template.fastlaneParametersFileName))
        
        do {
            if let renderedData = try factory.render(context: context(for: fastlaneParameters),
                                                     renderTemplate: StaticPath.Template.fastlaneParametersFileName) {
                XCTAssertEqual(String(data: renderedData, encoding: .utf8), expectedOutput)
            }
        } catch {
            XCTFail("'Try' should not throw - "+error.localizedDescription)
        }
    }
    
    private func context(for parameters: [CustomProperty]) -> [String: Any] {
        let fastlaneParameters = parameters.literal()
        let fastlaneEnvVars = parameters.envVars()
        guard !fastlaneParameters.isEmpty || !fastlaneEnvVars.isEmpty else { return [:] }
        
        let context = [
            "parameters": fastlaneParameters,
            "env_vars": fastlaneEnvVars
        ]
        return context
    }
}

fileprivate extension Sequence where Iterator.Element == CustomProperty {
    func envVars() -> [CustomProperty] {
        return self
            .filter({ $0.destination == .fastlane && $0.isEnvironmentVariable })
            .map { (property) -> CustomProperty in
                return CustomProperty(name: property.name,
                                      value: property.environmentValue,
                                      destination: property.destination)
            }
    }
    
    func literal() -> [CustomProperty] {
        return self
            .filter({ $0.destination == .fastlane && !$0.isEnvironmentVariable })
    }
}
