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
        
        print(FileManager.default.currentDirectoryPath)
        
        logger.logSection("$ ", item: "variants switch \(self.platform) \(self.variant)", color: .ios)
        self.defaultSpecs = self.specs ?? self.defaultSpecs
        
        do {
            let configurationHelper = ConfigurationHelper()
            guard let configuration = try configurationHelper
                .loadConfiguration(self.defaultSpecs, platform: self.platform)
                else {
                    fail(with: "Unable to load specs '\(self.defaultSpecs)'")
                    return
            }
            process(configuration)
            
        } catch {
            fail(with: "Unable to switch variants - Check your YAML spec")
        }
    }
    
    // MARK: - Private
    
    private func process(_ configuration: Configuration) {
        switchTo(configuration)
    }
    
    private func switchTo(_ configuration: Configuration) {
        
        switch self.platform {
        case .ios:
            guard let desiredVariant = configuration.ios?.variants.first(where: { $0.name == self.variant })
                else {
                    fail(with: "Variant \(self.variant) not found.")
                    return
            }
            logger.logInfo(item: "Found: \(desiredVariant.configIdSuffix)")
            
            let factory = XCConfigFactory()
            let configPath = Path(self.defaultSpecs).absolute().parent()
            
            configuration.ios?
                .targets.map { (key: $0.key, value: $0.value)}
                .forEach {
                    factory.createConfig(with: $0,
                                         variant: desiredVariant,
                                         xcodeProj: configuration.ios?.xcodeproj,
                                         configPath: configPath,
                                         addToXcodeProj: false)
            }
        case .android:
            guard let desiredVariant = configuration.android?.variants.first(where: { $0.name == self.variant })
                else {
                    fail(with: "Variant \(self.variant) not found.")
                    return
            }
            logger.logInfo(item: "Found: \(desiredVariant.name)")
            
            let factory = GradleScriptFactory()
            
            factory.createScript(with: configuration.android!,
                variant: desiredVariant)
        case .unknown:
            return
        }
    }
}
