//
//  Variants
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
    
    var logger: Logger { get }
}

extension Setup {
    public func decode(configuration: String) -> Configuration? {
        do {
            return try extractConfiguration(from: configuration, platform: platform)
        } catch {
            logger.logError("❌ ", item: error.localizedDescription)
        }
        return nil
    }
}

public class SetupDefault: Command, VerboseLogger, Setup {
    
    // --------------
    // MARK: Command information
    
    public var name: String = "setup"
    public var shortDescription: String = "Setup variants with fastlane included"
    
    // --------------
    // MARK: Configuration Properties
    
    @Key("-s", "--spec", description: "Use a different yaml configuration spec")
    var configuration: String?
    
    @Flag("--skip-fastlane", description: "Skip fastlane setup")
    var skipFastlane: Bool
    
    public var platform: Platform = .unknown
    public var logger: Logger { Logger.shared }
    
    public func execute() throws {
        logger.logSection("$ ", item: "variants \(platform)", color: .ios)
        
        guard let configurationData = try loadConfiguration(configuration) else {
            throw CLI.Error(message: "Unable to proceed creating build variants")
        }
        
        scanVariants(with: configurationData)
        setupFastlane(skipFastlane)
    }
    
    public func createVariants(for variants: [Variant]?) {}
    public func createConfig(with target: Target, variants: [Variant]?, pbxproj: String?) {}
    
    // --------------
    // MARK: Private methods
    
    private func scanVariants(with configuration: Configuration) {
        switch platform {
        case .ios:
            configuration.ios?.targets.map { (target: $0,
                                              pbx: configuration.ios?.pbxproj) }.forEach { result in
                createConfig(with: result.target.value,
                             variants: configuration.ios?.variants,
                             pbxproj: result.pbx)
            }
        case .android:
            break
        default:
            break
        }
    }
    
    private func setupFastlane(_ skip: Bool) {
        if skip {
            logger.logDebug(item: "Skipping Fastlane setup")
        } else {
            logger.logDebug(item: "Setting up Fastlane")
        }
    }
    
    // MARK: - Revamp
}

extension SetupDefault {
    private func loadConfiguration(_ path: String?) throws -> Configuration? {
        guard let path = path else {
            throw CLI.Error(message: "Error: Use '-s' to specify the configuration file")
        }
        
        let configurationPath = Path(path)
        guard !configurationPath.isDirectory else {
            throw CLI.Error(message: "Error: \(configurationPath) is a directory path")
        }
        
        let configuration = decode(configuration: path)
        return configuration
    }
}
