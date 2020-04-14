//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

final class SetupAndroid: Command, VerboseLogger {
    let name = "android"
    let shortDescription = "Setup multiple build flavours for Android project, alongside fastlane"
    
    @Param var configuration: String
    
    @Flag("-c", "--config", description: "Use a yaml configuration file")
    var isValidConfigurationFile: Bool
    
    @Flag("-f", "--include-fastlane", description: "Should setup fastlane")
    var includeFastlane: Bool
    
    func execute() throws {
        guard isValidConfigurationFile else {
            throw CLI.Error(message: "Error: Use '-c' to specify the configuration file")
        }
        
        let configurationPath = Path(configuration)
        guard !configurationPath.isDirectory else {
            throw CLI.Error(message: "Error: \(configurationPath) is a directory path")
        }
        
        if includeFastlane {
            log("Including Fastlane", indentationLevel: 2)
        }
        
        log("Done project setup!", indentationLevel: 2)
    }
}
