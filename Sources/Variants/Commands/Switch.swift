//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import SwiftCLI
import PathKit

final class Switch: Command, VerboseLogger {
    // --------------
    // MARK: Command information
    
    let name: String = "switch"
    let shortDescription: String = "Switch variants"
    
    // --------------
    // MARK: Configuration Properties
    
    @Param(validation: Validation.allowing(Platform.ios, Platform.android))
    var platform: Platform
    
    @Param
    var variant: String
    
    @Key("-s", "--spec", description: "Use a different yaml configuration spec")
    var specs: String?
    var defaultSpecs: String = "variants.yml"
    
    let logger = Logger.shared
    
    public func execute() throws {
        logger.logSection("$ ", item: "variants switch \(platform) \(variant)", color: .ios)
        defaultSpecs = specs ?? defaultSpecs
    
        do {
            let configurationHelper = ConfigurationHelper()
            guard let configuration = try configurationHelper
                .loadConfiguration(defaultSpecs, platform: platform)
            else {
                fail(with: "Unable to load specs '\(defaultSpecs)'")
                return
            }
            process(configuration)

        } catch {
            fail(with: "Unable to switch variants - Check your YAML spec")
        }
    }
    
    // MARK: - Private
    
    private func process(_ configuration: Configuration) {
        switch platform {
        case .ios:
            iOSSwitchTo(configuration.ios?.variants.first(where: { $0.name == variant }), with: configuration)
        case .android:
            androidSwitchTo(configuration.android?.variants.first(where: { $0.name == variant }), with: configuration)
        default:
            break
        }
    }
    private func androidSwitchTo(_ variant: AndroidVariant?, with configuration: Configuration) {
        // guard let desiredVariant = variant
        // else {
        //     fail(with: "Variant \(self.variant) not found.")
        //     return
        // }
        // logger.logInfo(item: "Found: \(desiredVariant.configIdSuffix)")
        
        // switch platform {
        // case .ios:
        //     let factory = XCConfigFactory()
        //     let configPath = Path(defaultSpecs).absolute().parent()
            
        //     configuration.ios?
        //         .targets.map { (key: $0.key, value: $0.value)}
        //         .forEach {
                    
        //         factory.createConfig(with: $0,
        //                              variant: desiredVariant,
        //                              xcodeProj: configuration.ios?.xcodeproj,
        //                              configPath: configPath,
        //                              addToXcodeProj: false)
        //     }

        // default:
        //     break
        // }
    }

    
    private func iOSSwitchTo(_ variant: iOSVariant?, with configuration: Configuration) {
        guard let desiredVariant = variant
        else {
            fail(with: "Variant \(self.variant) not found.")
            return
        }
        logger.logInfo(item: "Found: \(desiredVariant.configIdSuffix)")
        
        switch platform {
        case .ios:
            let factory = XCConfigFactory()
            let configPath = Path(defaultSpecs).absolute().parent()
            
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

