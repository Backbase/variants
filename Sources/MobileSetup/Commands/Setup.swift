//
//  MobileSetup
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import SwiftCLI
import PathKit
import Yams

public protocol Setup: YamlParser {
    var name: String { get }
    var shortDescription: String { get }
    var configurationData: Configuration? { get set }
    func decode(configuration: String) -> Configuration?
}

extension Setup {
    public func decode(configuration: String) -> Configuration? {
        do {
            return try extractConfiguration(from: configuration)
        } catch {
            log(error.localizedDescription)
        }
        return nil
    }
}

public class SetupDefault: Command, VerboseLogger, Setup {
    
    // --------------
    // MARK: Command information
    
    public var name: String = "setup"
    public var shortDescription: String = "Default description"
    
    // --------------
    // MARK: Configuration Properties
    
    @Key("-c", "--config", description: "Use a yaml configuration file")
    var configuration: String
    
    @Flag("-f", "--include-fastlane", description: "Should setup fastlane")
    var includeFastlane: Bool
    
    // --------------
    // MARK: Configuration Data
    
    public var configurationData: Configuration?
    
    public func execute() throws {
        try loadConfiguration(configuration)
        
        guard let configData = configurationData else {
            throw CLI.Error(message: "Unable to proceed creating build variants")
        }
        createVariants(for: configData.setupConfiguration.environments)
        
        if includeFastlane {
            log("Including Fastlane", indentationLevel: 1)
        }
    }
    
    // --------------
    // MARK: Public methods
    
    public func createVariants(for environments: [Environment]) {
        
    }
}

extension SetupDefault {
    private func loadConfiguration(_ path: String?) throws {
        guard let path = path else {
            throw CLI.Error(message: "Error: Use '-c' to specify the configuration file")
        }
        
        let configurationPath = Path(path)
        guard !configurationPath.isDirectory else {
            throw CLI.Error(message: "Error: \(configurationPath) is a directory path")
        }
        
        configurationData = decode(configuration: path)
    }
}
