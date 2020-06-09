//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

typealias DoesFileExist = (exists: Bool, path: Path?)

public enum Platform: String {
    case ios
    case android
    case unknown
}

final class Initializer: Command, VerboseLogger {
    // --------------
    // MARK: Command information
    
    let name: String = "init"
    let shortDescription: String = "Generate specs file - variants.yml"
    
    // --------------
    // MARK: Configuration Properties
    
    @Param(validation: Validation.allowing(Platform.ios.rawValue, Platform.android.rawValue))
    var platform: String
    
    public func execute() throws {
        log("--------------------------------------------", force: true)
        log("Running: variants init", force: true)
        
        guard
            let platformEnum = Platform(rawValue: platform)
        else {
            log("--------------------------------------------", force: true)
            log("Error: Parameter not specified: -p | --platform = ios | android\n", color: .red)
            throw CLI.Error(message: "Missing parameter")
        }
        
        let result = doesTemplateExist()
        guard result.exists, let path = result.path
        else {
            log("Error: Templates folder not found on '/usr/local/lib/coherent-swift/templates' or './Templates'", color: .red)
            exit(1)
        }
    
        log("Platform: \(platform)")
        log("--------------------------------------------", force: true)
        
        do {
            try generateConfig(path: path, platform: platformEnum)
        } catch {
            log("Error: ", color: .red, force: true)
            throw CLI.Error(message: "Couldn't generate YAML config")
        }
        log("Generated variants.yml\n", indentationLevel: 1, force: true)
        log("Edit the file above before continuing\n\n", color: .purple, force: true)
    }
    
    private func generateConfig(path: Path, platform: Platform) throws {
        guard path.absolute().exists else {
            throw CLI.Error(message: "Couldn't find template path")
        }
        try Task.run(bash: "cp \(path.absolute())/ios/variants-template.yml ./variants.yml", directory: nil)
    }
    
    private func doesTemplateExist() -> DoesFileExist {
        var path: Path?
        var exists = true
        
        let libTemplates = Path("/usr/local/lib/variants/templates")
        let localTemplates = Path("./Templates")
        
        if libTemplates.exists {
            path = libTemplates
        } else if localTemplates.exists {
            path = localTemplates
        } else {
            exists = false
        }
        
        return (exists: exists, path: path)
    }
}
