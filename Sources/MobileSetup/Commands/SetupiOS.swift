//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

final class SetupiOS: Command, VerboseLogger, Setup {
    
    // --------------
    // MARK: Command information
    
    let name = "ios"
    let shortDescription = "Setup multiple xcconfigs for iOS project, alongside fastlane"
    
    // --------------
    // MARK: Configuration Properties
    
    @Param var configuration: String
    
    @Flag("-c", "--config", description: "Use a yaml configuration file")
    var isValidConfigurationFile: Bool
    
    @Flag("-f", "--include-fastlane", description: "Should setup fastlane")
    var includeFastlane: Bool
    
    // --------------
    // MARK: Configuration Data
    
    internal var configurationData: Configuration?
    
    func execute() throws {
        try loadConfiguration(configuration)
        
        if includeFastlane {
            log("Including Fastlane", indentationLevel: 1)
        }
        
        log("Done project setup!")
    }
}

extension SetupiOS {
    private func loadConfiguration(_ path: String) throws {
        guard isValidConfigurationFile else {
            throw CLI.Error(message: "Error: Use '-c' to specify the configuration file")
        }
        
        let configurationPath = Path(path)
        guard !configurationPath.isDirectory else {
            throw CLI.Error(message: "Error: \(configurationPath) is a directory path")
        }
        
        configurationData = decode(configuration: path)
    }
}
