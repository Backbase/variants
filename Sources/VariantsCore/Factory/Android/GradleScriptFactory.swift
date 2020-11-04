//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation
import PathKit

class GradleScriptFactory {
    
    /// Create `gradleScripts/variants.gradle` file inside project's path
    /// - Parameters:
    ///   - configuration: Android configuration from `variants.yml`
    ///   - variant: Desired project variant.
    func createScript(with configuration: AndroidConfiguration, variant: AndroidVariant) {
        var gradleFileContent = ""
        
        //Write the variant data
        gradleFileContent.appendLine("// ==== Variant values ==== ")
        gradleFileContent.addGradleDefinition("versionName", value: variant.versionName)
        gradleFileContent.addGradleValueDefinition("versionCode", value: variant.versionCode)
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
}

private struct WrapperGradleTask{
    let name: String
    let dependsOnTaskWithName: String
    let description: String
}

fileprivate extension String {
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
    
    // This will add the value without quotes
    // This is useful in cases of versionCode which should be
    // represented as an int and not a string.
    mutating func addGradleValueDefinition(_ name: String, value: String) {
        self.appendLine("rootProject.ext.\(name) = \(value.envVarValue() ?? value)")
    }
}
