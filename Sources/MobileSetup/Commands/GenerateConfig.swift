//
//  File.swift
//  
//
//  Created by Arthur Alves on 14/04/2020.
//

import Foundation
import PathKit
import SwiftCLI

enum Platform: String {
    case ios
    case android
}

final class GenerateConfig: Command, VerboseLogger {
    // --------------
    // MARK: Command information
    
    let name: String = "init"
    let shortDescription: String = "Generate project yml file that is used by MobileSetup and XcodeGen"
    
    // --------------
    // MARK: Configuration Properties
    
    @Key("-p", "--platform", description: "Initialize config for platform: ios | android")
    var platform: String
    
    public func execute() throws {
        log("--------------------------------------------", indentationLevel: 1, force: true)
        log("Running: mobile-setup init", indentationLevel: 1, force: true)
        
        guard
            let platformString = platform,
            let platformEnum = Platform(rawValue: platformString)
        else {
            log("--------------------------------------------", indentationLevel: 1, force: true)
            throw CLI.Error(message: "Parameter not specified: -p | --platform = ios | android")
        }
    
        log("Platform: \(runningPlatform)", indentationLevel: 1)
        log("--------------------------------------------", indentationLevel: 1, force: true)

        try? generateConfig(path: Path("/usr/local/lib/mobile-setup/templates"), platform: platformEnum)
        
        log("Generated mobile-setup.yml\n", indentationLevel: 2, force: true)
        log("Edit the file above before continuing\n\n", indentationLevel: 1, color: .purple, force: true)
    }
    
    private func generateConfig(path: Path, platform: Platform) throws {
        guard path.absolute().exists else {
            throw CLI.Error(message: "Couldn't find template path")
        }
        try? Task.run(bash: "cp \(path.absolute())/mobile-setup-\(platform.rawValue)-template.yml ./mobile-setup.yml", directory: nil)
    }
}
