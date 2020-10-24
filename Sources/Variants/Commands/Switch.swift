//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import ArgumentParser
import PathKit

struct Switch: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "switch",
        abstract: "Switch variants"
    )
    
    // --------------
    // MARK: Configuration Properties
    
    @Argument()
    var variant: String
    
    @Option(name: .shortAndLong, help: "'ios' or 'android'")
    var platform: Platform
    
    @Option(name: .shortAndLong, help: "Use a different yaml configuration spec")
    var spec: String = "variants.yml"
    
    @Flag(name: .shortAndLong)
    var verbose = false
    
    mutating func run() throws {
        let logger = Logger(verbose: verbose)
        logger.logSection("$ ", item: "variants switch \(variant)", color: .ios)
        
        do {
            let configurationHelper = ConfigurationHelper(verbose: verbose)
            guard let configuration = try configurationHelper
                .loadConfiguration(spec, platform: platform)
            else {
                throw RuntimeError("Unable to load specs '\(spec)'")
            }
            process(configuration)

        } catch {
            throw RuntimeError("Unable to switch variants - Check your YAML spec")
        }
    }
    
    // MARK: - Private
    
    private func process(_ configuration: Configuration) {
        var variantObj: Variant?
        switch platform {
        case .ios:
            variantObj = configuration.ios?.variants.first(where: { $0.name == variant })
        case .android:
            variantObj = configuration.android?.variants.first(where: { $0.name == variant })
        }
        
        try? switchTo(variantObj, with: configuration)
    }
    
    private func switchTo(_ variant: Variant?, with configuration: Configuration) throws {
        guard let desiredVariant = variant else {
            throw ValidationError("Variant \(self.variant) not found.")
        }
        Logger.shared.logInfo(item: "Found: \(desiredVariant.configIdSuffix)")
        
        switch platform {
        case .ios:
            let factory = XCConfigFactory(logLevel: verbose)
            let configPath = Path(spec).absolute().parent()
            
            configuration.ios?
                .targets.map { (key: $0.key, value: $0.value)}
                .forEach {
                    
                factory.createConfig(with: $0,
                                     variant: desiredVariant,
                                     xcodeProj: configuration.ios?.xcodeproj,
                                     configPath: configPath,
                                     addToXcodeProj: false)
            }

        default:
            break
        }
    }
}

