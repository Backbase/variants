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
        return extractConfiguration(from: configuration, platform: platform)
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
    var specs: String?
    var defaultSpecs: String = "variants.yml"
    
    @Flag("--skip-fastlane", description: "Skip fastlane setup")
    var skipFastlane: Bool
    
    public var platform: Platform = .unknown
    public var logger: Logger { Logger.shared }
    
    public func execute() throws {
        logger.logSection("$ ", item: "variants \(platform)", color: .ios)
        
        defaultSpecs = specs ?? defaultSpecs
        guard let configuration = try loadConfiguration(defaultSpecs) else {
            throw CLI.Error(message: "Unable to proceed creating build variants")
        }
        
        scanVariants(with: configuration)
        setupFastlane(skipFastlane)
    }
    
    public func createVariants(for variants: [Variant]?) {}
    public func createConfig(with target: NamedTarget, variants: [Variant]?, xcodeProj: String?) {}
    
    // --------------
    // MARK: Private methods
    
    private func scanVariants(with configuration: Configuration) {
        switch platform {
        case .ios:
            configuration.ios?.targets.map { (key: $0.key,
                                              value: $0.value) }.forEach { result in
                createConfig(with: result,
                             variants: configuration.ios?.variants,
                             xcodeProj: configuration.ios?.xcodeproj)
            }
        case .android:
            break
        default:
            break
        }
    }
    
    private func setupFastlane(_ skip: Bool) {
        if skip {
            logger.logInfo("Skiped Fastlane setup", item: "")
        } else {
            logger.logInfo("Setting up Fastlane", item: "")
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
