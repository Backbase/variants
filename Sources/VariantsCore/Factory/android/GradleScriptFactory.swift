//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation
import PathKit

struct GradleScriptFactory {
    
    /// Create `gradleScripts/variants.gradle` file inside project's path
    /// - Parameters:
    ///   - configuration: Android configuration from `variants.yml`
    ///   - variant: Desired project variant.
    func createScript(with configuration: AndroidConfiguration, variant: AndroidVariant) {
        let fm = FileManager.default
        var gradleFileContent = ""
        var exportVariablesFileContent = ""
        
        var fastlaneConfig = FastlaneConfig(parameters: [String: String]())
        let consolePrinter = StdoutPrinter()
        
        //Write the variant data
        gradleFileContent.appendLine("// ==== Variant values ==== ")
        gradleFileContent.addGradleDefinition("versionName", value: variant.versionName)
        gradleFileContent.addGradleDefinition("versionCode", value: variant.versionCode)
        gradleFileContent.addGradleDefinition("appIdentifier", value: configuration.appIdentifier+variant.configIdSuffix)
        gradleFileContent.addGradleDefinition("appName", value: configuration.appName+variant.configName)
        
        if let signing = configuration.signing {
            //Write the signing data
            gradleFileContent.appendLine("\n// ==== Signing values ==== ")
            gradleFileContent.addGradleDefinition("signingKeyAlias", value: signing.keyAlias)
            gradleFileContent.addGradleDefinition("signingKeyPassword", value: signing.keyPassword)
            gradleFileContent.addGradleDefinition("signingStoreFile", value: signing.storeFile)
            gradleFileContent.addGradleDefinition("signingStorePassword", value: signing.storePassword)
        }
        
        //Write the custom properties
        add(customProperties: variant.custom, header: "\n// ==== Variant custom values ==== ", &gradleFileContent, &exportVariablesFileContent, &fastlaneConfig)
        add(customProperties: configuration.custom, header: "\n// ==== Custom values ==== ", &gradleFileContent, &exportVariablesFileContent, &fastlaneConfig)
        
        //Write wrapper gradle tasks
        gradleFileContent.appendLine("\n// ==== Wrapper gradle tasks ==== ")
        
        gradleFileContent.addWrapperGradleTasks([
            WrapperGradleTask(name: "vBuild", dependsOnTaskWithName: variant.taskBuild, description: "Wrapper Gradle task used for building the application"),
            WrapperGradleTask(name: "vUnitTests", dependsOnTaskWithName: variant.taskUnitTest, description: "Wrapper Gradle task used for executing the Unit Tests"),
            WrapperGradleTask(name: "vUITests", dependsOnTaskWithName: variant.taskUitest, description: "Wrapper Gradle task used for executing the UI Tests")
        ])
        
        //Write the actual files
        gradleFileContent.writeGradleScript(with: configuration)
        
        if !exportVariablesFileContent.isEmpty {
            if let path = exportVariablesFileContent.writeToTemporaryFile() {
                consolePrinter.print(item: "EXPORT_ENVIRONMENTAL_VARIABLES_PATH=\(path)")
            } else {
                Logger.shared.logError(item: "Could not generate the file for the enviromental variables")
            }
        }
        
        let fastlaneParamPath = configuration.path + "/" + Constants.Fastlane.parametersPath
        
        if(!fastlaneConfig.parameters.isEmpty) {
            if(fm.fileExists(atPath: fastlaneParamPath)) {
                let fastlaneVariantVariabelsUrl = URL(fileURLWithPath: fastlaneParamPath)
                    .appendingPathComponent(Constants.Fastlane.variantGeneratedParametersFileName)
                do {
                    if(fm.fileExists(atPath: fastlaneVariantVariabelsUrl.absoluteString))
                    {
                        try fm.removeItem(at: fastlaneVariantVariabelsUrl)
                    }
                    let fastlanePropsStringData = try RubyPropertiesEncoder().encode(fastlaneConfig).data(using: .utf8)
                    let fileCreated = fm.createFile(atPath: fastlaneVariantVariabelsUrl.path, contents: fastlanePropsStringData, attributes: nil)
                    if(!fileCreated) {
                        throw "Could not generate the file for the fastlane variables"
                    }
                } catch {
                    Logger.shared.logError("❌ ", item: "Could not generate the file for the fastlane variables")
                }
            } else {
                Logger.shared.logError("❌ ", item: "\(fastlaneParamPath) not found. Unable to store configuration value for key \(variant.name) using \"fastlane\" destination.")
            }
        }
    }
    
    func add(customProperties properties: [CustomProperty]?, header: String, _ gradleFileContent: inout String, _ exportVariablesFileContent: inout String, _ fastlaneParameters: inout FastlaneConfig) {
        
        var customVariablesHeaderAdded = false
        properties?.forEach { prop in
            switch(prop.destination) {
            case .gradle:
                if(!customVariablesHeaderAdded) {
                    gradleFileContent.appendLine(header)
                    customVariablesHeaderAdded = true
                }
                gradleFileContent.addGradleDefinition(prop.name, value: prop.value)
            case .envVar:
                exportVariablesFileContent.addExportVariable(prop.name, value: prop.value)
            case .fastlane:
                fastlaneParameters.parameters[prop.name] = prop.value
            }
        }
    }
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
            try fm.createDirectory(atPath: destinationFolderPath, withIntermediateDirectories: true, attributes: nil)
            fm.createFile(atPath: destionationFilePath, contents: self.data(using: .utf8), attributes: nil)
        } catch {
            Logger.shared.logError(item: "Could not generate gradle script:\n\(error.localizedDescription)")
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
