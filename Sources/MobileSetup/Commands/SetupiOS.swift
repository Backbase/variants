//
//  File.swift
//  
//
//  Created by Arthur Alves on 14/04/2020.
//

import Foundation
import PathKit
import SwiftCLI

final class SetupiOS: Command, VerboseLogger {
    let name = "ios"
    let shortDescription = "Setup multiple xcconfigs for iOS project, alongside fastlane"
    
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
