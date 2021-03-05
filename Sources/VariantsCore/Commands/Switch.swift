//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import ArgumentParser
import PathKit

public struct Switch: ParsableCommand {
    public init() {}
    
    public static var configuration = CommandConfiguration(
        commandName: "switch",
        abstract: "Switch variants"
    )
    
    // MARK: - Configuration Properties
    
    @Option(help: "Desired variant")
    var variant: String = "default"
    
    @Option(name: .shortAndLong, help: "'ios' or 'android'")
    var platform: String = ""
    
    @Option(name: .shortAndLong, help: "Use a different yaml configuration spec")
    var spec: String = "variants.yml"
    
    @Flag(name: [.customLong("timestamps", withSingleDash: false),
                 .customShort("t")], help: "Show timestamps.")
    var showTimestamps = false
    
    @Flag(name: .shortAndLong, help: "Log tech details for nerds")
    var verbose = false
    
    public mutating func run() throws {
        let logger = Logger(verbose: verbose, showTimestamp: showTimestamps)
        logger.logSection("$ ", item: "variants switch --variant \(variant)", color: .ios)
        
        let detectedPlatform = try PlatformDetector.detect(fromArgument: platform)
        let project = ProjectFactory.from(platform: detectedPlatform, logger: logger)
        try project.switch(to: variant, spec: spec, verbose: verbose)
    }
}
