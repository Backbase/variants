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
    let configurationHelper = ConfigurationHelper()
    
    public func execute() throws {
        logger.logSection("$ ", item: "variants switch \(platform) \(variant)", color: .ios)
    
        defaultSpecs = specs ?? defaultSpecs
        do {
            guard let configuration = try configurationHelper
                .loadConfiguration(defaultSpecs, platform: platform)
            else {
                fail(with: "Unable to load specs '\(defaultSpecs)'")
                return
            }
            
            var variantObj: Variant?
            switch platform {
            case .ios:
                variantObj = configuration.ios?.variants.first(where: { $0.name == variant })
            case .android:
                variantObj = configuration.android?.variants.first(where: { $0.name == variant })
            default:
                break
            }
            
            switchTo(variantObj, with: configuration)
            
        } catch {
            fail(with: error.localizedDescription)
        }
    }
    
    // MARK: - Private
    
    private func switchTo(_ variant: Variant?, with configuration: Configuration) {
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
                .targets.map { (target: $0, xcodeproj: configuration.ios?.xcodeproj) }
                .forEach { result in
                    
                    factory.createConfig(with: result.target.value,
                                         variant: desiredVariant,
                                         xcodeProj: result.xcodeproj,
                                         configPath: configPath)
            }

        default:
            break
        }
    }
}

