//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//

import Foundation
import PathKit
import SwiftCLI

struct WrapperGradleTask{
    let name: String
    let dependsOnTaskWithName: String
    let description: String
}

struct GradleScriptFactory {
    
    func createScript(with configuration: AndroidConfiguration, variant: AndroidVariant) {
        var gradleFileContent = ""
        var exportVariablesFileContent = ""
        var fastlaneVariablesFileContent = "{\n"
        
        //Write the variant data
        gradleFileContent.appendLine("// ==== Variant values ==== ")
        gradleFileContent.addGradleDefinition("versionName", value: variant.versionName)
        gradleFileContent.addGradleDefinition("versionCode", value: variant.versionCode)
        gradleFileContent.addGradleDefinition("appIdentifier", value: variant.appIdentifier)
        gradleFileContent.addGradleDefinition("appName", value: variant.appName)
        
        if let signing = configuration.signing {
            //Write the signing data
            gradleFileContent.appendLine("// ==== Signing values ==== ")
            gradleFileContent.addGradleDefinition("signingKeyAlias", value: signing.keyAlias)
            gradleFileContent.addGradleDefinition("signingKeyPassword", value: signing.keyPassword)
            gradleFileContent.addGradleDefinition("signingStoreFile", value: signing.storeFile)
            gradleFileContent.addGradleDefinition("signingStorePassword", value: signing.storePassword)
        }
        
        //Write the custom properties
        add(customProperties: variant.custom, header: "// ==== Variant custom values ==== ", &gradleFileContent, &exportVariablesFileContent, &fastlaneVariablesFileContent)
        add(customProperties: configuration.custom, header: "// ==== Custom values ==== ", &gradleFileContent, &exportVariablesFileContent, &fastlaneVariablesFileContent)
        
        //Write wrapper gradle tasks
        gradleFileContent.appendLine("// ==== Wrapper gradle tasks ==== ")
        
        gradleFileContent.addWrapperGradleTasks([
            WrapperGradleTask(name: "vBuild", dependsOnTaskWithName: variant.taskBuild, description: "Wrapper Gradle task used for building the application"),
            WrapperGradleTask(name: "vUnitTests", dependsOnTaskWithName: variant.taskUnitTest, description: "Wrapper Gradle task used for executing the Unit Tests"),
            WrapperGradleTask(name: "vUITests", dependsOnTaskWithName: variant.taskUitest, description: "Wrapper Gradle task used for executing the UI Tests"),
        ])
        
        //Write the actual files
        gradleFileContent.writeGradleScript(with: configuration)
        
        if let path = exportVariablesFileContent.writeTemporaryFile() {
            Logger.shared.logInfo(item: "EXPORT_ENVIRONMENTAL_VARIABLES_PATH=\(path)")
        } else {
            Logger.shared.logError(item: "Could not generate the file for the enviromental variables")
        }
        fastlaneVariablesFileContent = String(fastlaneVariablesFileContent.dropLast(2))
        fastlaneVariablesFileContent.appendLine("\n}")
        if let path = fastlaneVariablesFileContent.writeTemporaryFile() {
            Logger.shared.logInfo(item: "EXPORT_FASTLANE_PARAMETERS_PATH=\(path)")
        } else {
            Logger.shared.logError(item: "Could not generate the file for the enviromental variables")
        }
    }
    
    func add(customProperties properties: [CustomProperty]?, header: String, _ gradleFileContent: inout String, _ exportVariablesFileContent: inout String, _ fastlaneVariablesFileContent: inout String) {
        
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
                exportVariablesFileContent.addExportVariable(prop.name,value: prop.value)
            case .fastlane:
                fastlaneVariablesFileContent.addFastlaneParameter(prop.name,value: prop.value)
            }
        }
    }
}

fileprivate extension String {
    
    func writeTemporaryFile() -> String? {
        do {
        return try FileManager.default.writeTemporaryFile(withContent: self)
        }
        catch {
            return nil
        }
    }
    
    func writeGradleScript(with configuration:AndroidConfiguration) {
        let fm = FileManager.default
        let destinationFolderPath = configuration.path + "/gradleScripts"
        let destionationFilePath = destinationFolderPath + "/variants.gradle"
        
        do {
            try fm.createDirectory(atPath: destinationFolderPath, withIntermediateDirectories: true, attributes: nil)
            fm.createFile(atPath: destionationFilePath, contents: self.data(using: .utf8
            ), attributes: nil)
        } catch
        {
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
            self.appendLine(String(format: "def %@ = task %@", element.name,element.name))
            let isFirst = index == 0
            if(isFirst )
            { dependsOnScriptList.append(String(format: dependsOnScript,
                                                "",
                                                element.dependsOnTaskWithName, element.name)) }
            else {
                dependsOnScriptList.append(String(format: dependsOnScript,
                                                  " else ",
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
    mutating func addExportVariable(_ name: String, value: String) {
        self.appendLine("export \(name)=\(value.envVarValue() ?? value)")
    }
    mutating func addFastlaneParameter(_ name: String, value: String) {
        self.appendLine("   :\(name) => \"\(value.envVarValue() ?? value)\",")
    }
}
