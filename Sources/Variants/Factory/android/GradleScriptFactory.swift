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
        
        //Write the variant data
        gradleFileContent.appendLine("// ==== Variant values ==== ")
        gradleFileContent.addGradleDefinition("versionName", value: variant.versionName)
        gradleFileContent.addGradleDefinition("versionCode", value: variant.versionCode)
        gradleFileContent.addGradleDefinition("appIdentifier", value: variant.appIdentifier)
        gradleFileContent.addGradleDefinition("appName", value: variant.appName)
        
        var customVariablesHeaderAdded = false
        variant.custom?.forEach { prop in
            switch(prop.destination) {
            case .gradle:
                if(!customVariablesHeaderAdded) {
                    gradleFileContent.appendLine("// ==== Variant custom values ==== ")
                    customVariablesHeaderAdded = true
                }
                gradleFileContent.addGradleDefinition(prop.name, value: prop.value)
            case .envVar:
                exportVariablesFileContent.addExportVariable(prop.name,value: prop.value)
            }
        }
        //TODO: improve this duplicate
        customVariablesHeaderAdded = false
        configuration.custom?.forEach { prop in
            switch(prop.destination) {
            case .gradle:
                if(!customVariablesHeaderAdded) {
                    gradleFileContent.appendLine("// ==== Custom values ==== ")
                    customVariablesHeaderAdded = true
                }
                gradleFileContent.addGradleDefinition(prop.name, value: prop.value)
            case .envVar:
                exportVariablesFileContent.addExportVariable(prop.name,value: prop.value)
            }
        }
        
        //Write wrapper gradle tasks
        gradleFileContent.appendLine("// ==== Wrapper gradle tasks ==== ")
        
        let wrapperGradleTasks = [
            WrapperGradleTask(name: "vBuild", dependsOnTaskWithName: variant.taskBuild, description: "Wrapper Gradle task used for building the application"),
            WrapperGradleTask(name: "vUnitTests", dependsOnTaskWithName: variant.taskUnitTest, description: "Wrapper Gradle task used for executing the Unit Tests"),
            WrapperGradleTask(name: "vUITests", dependsOnTaskWithName: variant.taskUitest, description: "Wrapper Gradle task used for executing the UI Tests"),
        ]
        
        gradleFileContent.addWrapperGradleTasks(wrapperGradleTasks)
        gradleFileContent.writeGradleScript(with: configuration)
        if let path = exportVariablesFileContent.writeTemporaryFile() {
            //TODO: Return path to stdout
            Logger.shared.logInfo(item: "Written variables at \(path)")
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
            let fileCreated = fm.createFile(atPath: destionationFilePath, contents: self.data(using: .utf8
            ), attributes: nil)
            print(fileCreated) //TODO: Improve
        } catch
        {
            print(error)
            //TODO: Improve handle error
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
}
