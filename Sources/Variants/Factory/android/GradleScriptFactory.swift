//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//
import PathKit
import Foundation

struct WrapperGradleTask{
    let name: String
    let dependsOnTaskWithName: String
    let description: String
}

struct GradleScriptFactory {
    
    fileprivate func writeFile(_ configuration: AndroidConfiguration, _ fileContent: String) {
        
        let fm = FileManager.default
        let destinationFolderPath = configuration.path + "/gradleScripts"
        let destionationFilePath = destinationFolderPath + "/variants.gradle"
        
        do {
            try fm.createDirectory(atPath: destinationFolderPath, withIntermediateDirectories: true, attributes: nil)
            let fileCreated = fm.createFile(atPath: destionationFilePath, contents: fileContent.data(using: .utf8
            ), attributes: nil)
            print(fileCreated) //TODO: Improve
        } catch
        {
            print(error)
            //TODO: Improve handle error
        }
    }
    
    
    
    func createScript(with configuration: AndroidConfiguration,
                      variant: AndroidVariant)
    {
        var fileContent = ""
        
        //Write the variant data
        fileContent.appendLine("// ==== Variant values ==== ")
        fileContent.addDefinition("versionName", value: variant.versionName)
        fileContent.addDefinition("versionCode", value: variant.versionCode)
        fileContent.addDefinition("appIdentifier", value: variant.appIdentifier)
        fileContent.addDefinition("appName", value: variant.appName)
        
        //Write wrapper gradle tasks
        fileContent.appendLine("// ==== Wrapper gradle tasks ==== ")
        
        let wrapperGradleTasks = [
            WrapperGradleTask(name: "vBuild", dependsOnTaskWithName: variant.taskBuild, description: "Wrapper Gradle task used for building the application"),
            WrapperGradleTask(name: "vUnitTests", dependsOnTaskWithName: variant.taskUnitTest, description: "Wrapper Gradle task used for executing the Unit Tests"),
            WrapperGradleTask(name: "vUITests", dependsOnTaskWithName: variant.taskUitest, description: "Wrapper Gradle task used for executing the UI Tests"),
        ]
        fileContent.addWrapperGradleTasks(wrapperGradleTasks)
        
        writeFile(configuration, fileContent)
    }
}

fileprivate extension String {
    
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
        
        
        //        self.appendLine("//" + description)
        //        self.appendLine(String(format: "def %@ = task %@", name,name))
        //        let dependsOnScript = """
        //        tasks.whenTaskAdded { task ->
        //            if (task.name == %@) {
        //               %@.dependsOn(task)
        //            }
        //        }
        //        """
        //        self.appendLine(String(format:dependsOnScript, value, name))
    }
    
    mutating func addDefinition(_ name: String, value: String) {
        
        var value = value
        
        let regexPattern = #"^\{\{ envVars.(?<name>.*) \}\}"#
        
        let regex = try? NSRegularExpression(
            pattern: regexPattern
        )
        
        if let match = regex?.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.utf16.count)) {
            if #available(OSX 10.13, *) {
                if let envVarName = Range(match.range(withName: "name"), in: value) {
                    guard let envVarValue = ProcessInfo.processInfo.environment[String(value[envVarName])] else {
                        return
                    }
                    value = envVarValue
                } else {
                    //TODO: No idea what to do here
                }
            }
        }
        
        self.appendLine(String(format: #"rootProject.ext.%@ = "%@""#, name, value))
    }
    
    
}
