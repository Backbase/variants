//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//
import PathKit
import Foundation

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
        
        writeFile(configuration, fileContent)
    }
}

fileprivate extension String {
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
