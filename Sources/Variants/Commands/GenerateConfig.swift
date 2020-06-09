//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

public enum Platform: String {
    case ios
    case android
    case unknown
}

final class GenerateConfig: Command, VerboseLogger {
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
        log("Running: mobile-setup init", force: true)
        
        guard
            let platformEnum = Platform(rawValue: platform)
        else {
            log("--------------------------------------------", force: true)
            log("Error: Parameter not specified: -p | --platform = ios | android\n", color: .red)
            throw CLI.Error(message: "Missing parameter")
        }
    
        log("Platform: \(platform)")
        log("--------------------------------------------", force: true)
        
        do {
            try generateConfig(path: Path("/usr/local/lib/mobile-setup/templates"), platform: platformEnum)
        } catch {
            log("Error: ", color: .red, force: true)
            throw CLI.Error(message: "Couldn't generate YAML config")
        }
        log("Generated mobile-setup.yml\n", indentationLevel: 1, force: true)
        log("Edit the file above before continuing\n\n", color: .purple, force: true)
    }
    
    private func generateConfig(path: Path, platform: Platform) throws {
        guard path.absolute().exists else {
            throw CLI.Error(message: "Couldn't find template path")
        }
        try Task.run(bash: "cp \(path.absolute())/mobile-setup-\(platform.rawValue)-template.yml ./mobile-setup.yml", directory: nil)
    }
}
