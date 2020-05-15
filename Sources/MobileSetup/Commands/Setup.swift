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
    var platform: Platform { get set }
    
    func decode(configuration: String) -> Configuration?
}

extension Setup {
    public func decode(configuration: String) -> Configuration? {
        do {
            return try extractConfiguration(from: configuration, platform: platform)
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
    
    public var platform: Platform = .unknown
    
    public func execute() throws {
        guard let configurationData = try loadConfiguration(configuration) else {
            throw CLI.Error(message: "Unable to proceed creating build variants")
        }
        
        scanVariants(with: configurationData)
        setupFastlane(includeFastlane)
    }
    
    public func createVariants(for environments: [Environment]?) {}
    
    // --------------
    // MARK: Private methods
    
    private func scanVariants(with configuration: Configuration) {
        var environments: [Environment]?
        switch platform {
        case .ios:
            environments = configuration.ios?.environments
        case .android:
            environments = configuration.android?.environments
        default:
            break
        }
        createVariants(for: environments)
    }
    
    private func setupFastlane(_ include: Bool) {
        if include {
            log("Setting up Fastlane", indentationLevel: 1)
        } else {
            log("Skipping Fastlane setup", indentationLevel: 1)
        }
    }
    
}

extension SetupDefault {
    private func loadConfiguration(_ path: String?) throws -> Configuration? {
        guard let path = path else {
            throw CLI.Error(message: "Error: Use '-c' to specify the configuration file")
        }
        
        let configurationPath = Path(path)
        guard !configurationPath.isDirectory else {
            throw CLI.Error(message: "Error: \(configurationPath) is a directory path")
        }
        
        let configuration = decode(configuration: path)
        return configuration
    }
}
