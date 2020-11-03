//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation
import PathKit

class GradleScriptFactory {
    
    init(consolePrinter: StdoutPrinter = StdoutPrinter()) {
        self.consolePrinter = consolePrinter
    }
    
    // swiftlint:disable function_body_length
    
    /// Create `gradleScripts/variants.gradle` file inside project's path
    /// - Parameters:
    ///   - configuration: Android configuration from `variants.yml`
    ///   - variant: Desired project variant.
    func createScript(with configuration: AndroidConfiguration, variant: AndroidVariant) {
        var gradleFileContent = ""
        
        //Write the variant data
        gradleFileContent.appendLine("// ==== Variant values ==== ")
        gradleFileContent.addGradleDefinition("versionName", value: variant.versionName)
        gradleFileContent.addGradleDefinition("versionCode", value: variant.versionCode)
        gradleFileContent.addGradleDefinition("appIdentifier",
                                              value: configuration.appIdentifier+variant.configIdSuffix)
        gradleFileContent.addGradleDefinition("appName", value: configuration.appName+variant.configName)
        
        if let signing = configuration.signing {
            //Write the signing data
            gradleFileContent.appendLine("\n// ==== Signing values ==== ")
            gradleFileContent.addGradleDefinition("signingKeyAlias", value: signing.keyAlias)
            gradleFileContent.addGradleDefinition("signingKeyPassword", value: signing.keyPassword)
            gradleFileContent.addGradleDefinition("signingStoreFile", value: signing.storeFile)
            gradleFileContent.addGradleDefinition("signingStorePassword", value: signing.storePassword)
        }
        
        // Append custom gradle properties
        gradleFileContent = appendGradleProperties(variant.custom,
                                                   using: "\n// ==== Variant custom values ==== ",
                                                   to: gradleFileContent)
        
        gradleFileContent = appendGradleProperties(configuration.custom,
                                                   using: "\n// ==== Custom values ==== ",
                                                   to: gradleFileContent)
        
        // Append custom environment variables
        let customProperties: [CustomProperty] = (variant.custom ?? []) + (configuration.custom ?? [])
        storeEnvironmentProperties(customProperties)
        
        
        // Write wrapper gradle tasks
        gradleFileContent.appendLine("\n// ==== Wrapper gradle tasks ==== ")
        
        gradleFileContent.addWrapperGradleTasks([
            WrapperGradleTask(name: "vBuild", dependsOnTaskWithName: variant.taskBuild,
                              description: "Wrapper Gradle task used for building the application"),
            WrapperGradleTask(name: "vUnitTests", dependsOnTaskWithName: variant.taskUnitTest,
                              description: "Wrapper Gradle task used for executing the Unit Tests"),
            WrapperGradleTask(name: "vUITests", dependsOnTaskWithName: variant.taskUitest,
                              description: "Wrapper Gradle task used for executing the UI Tests")
        ])
        
        //Write the actual files
        gradleFileContent.writeGradleScript(with: configuration)
    }
    // swiftlint:enable function_body_length
    
    
    /// Append properties whose destination is '.project' as gradle properties
    /// to a string content
    /// - Parameters:
    ///   - properties: Optional array of CustomProperty
    ///   - header: String header preceding the properties
    ///   - content: String where these properties will be appended to
    /// - Returns: New content containing the gradle properties added
    func appendGradleProperties(_ properties: [CustomProperty]?,
                                using header: String,
                                to content: String) -> String {
        
        // Add Properties to Gradle file
        let gradleProperties = properties?.filter { $0.destination == .project } ?? []
        guard !gradleProperties.isEmpty else { return content }
        var mutableContent = content
        mutableContent.appendLine(header)
        gradleProperties.forEach { property in
            mutableContent.addGradleDefinition(property.name, value: property.value)
        }
        return mutableContent
    }
    
    /// Store  properties whose destination is '.envVar' as environment variables
    /// on temporary file.
    /// - Parameters:
    ///   - properties: Optional array of CustomProperty
    func storeEnvironmentProperties(_ properties: [CustomProperty]?) {
        let environmentProperties = properties?.filter { $0.destination == .envVar } ?? []
        guard !environmentProperties.isEmpty else { return }
        var mutableContent = ""
        environmentProperties.forEach { property in
            mutableContent.appendAsExportVariable(property.name, value: property.value)
        }
        
        if let path = mutableContent.writeToTemporaryFile() {
            consolePrinter.print(item: "EXPORT_ENVIRONMENTAL_VARIABLES_PATH=\(path)")
        } else {
            Logger.shared.logError(item: """
            Could not generate the temporary file for the environment variables.
            """)
        }
    }
    
    private let consolePrinter: StdoutPrinter
}

private struct WrapperGradleTask{
    let name: String
    let dependsOnTaskWithName: String
    let description: String
}

fileprivate extension String {
    func writeToTemporaryFile() -> String? {
        do {
            return try FileManager.default.writeTemporaryFile(withContent: self)
        } catch {
            return nil
        }
    }
    
    func writeGradleScript(with configuration: AndroidConfiguration) {
        let fm = FileManager.default
        let destinationFolderPath = configuration.path + "/gradleScripts"
        let destionationFilePath = destinationFolderPath + "/variants.gradle"
        
        do {
            try fm.createDirectory(atPath: destinationFolderPath,
                                   withIntermediateDirectories: true, attributes: nil)
            fm.createFile(atPath: destionationFilePath,
                          contents: self.data(using: .utf8), attributes: nil)
        } catch {
            Logger.shared.logError(item: """
                Could not generate gradle script:\n\(error.localizedDescription)
            """)
        }
    }
    
    mutating func addWrapperGradleTasks(_ tasks: [WrapperGradleTask]) {
        let dependsOnScript = #"""
        %@if (task.name == "%@") {
                %@.dependsOn(task)
            }
        """#
        
        var dependsOnScriptList = ""
        
        for (index, element) in tasks.enumerated() {
            self.appendLine(String(format: "def %@ = task %@", element.name, element.name))
            let isFirst = index == 0
            if isFirst {
                dependsOnScriptList.append(String(format: dependsOnScript, "",
                                                  element.dependsOnTaskWithName, element.name))
                
            } else {
                dependsOnScriptList.append(String(format: dependsOnScript, " else ",
                                                  element.dependsOnTaskWithName, element.name))
            }
        }
        
        let whenTaskAddedScript = """
        tasks.whenTaskAdded { task ->
            %@
        }
        """
        
        self.appendLine(String(format: whenTaskAddedScript, dependsOnScriptList))
    }
    
    mutating func addGradleDefinition(_ name: String, value: String) {
        self.appendLine("rootProject.ext.\(name) = \"\(value.envVarValue() ?? value)\"")
    }
}
