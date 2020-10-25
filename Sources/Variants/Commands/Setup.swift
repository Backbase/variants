//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import ArgumentParser
import PathKit
import Yams

struct Setup: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "setup",
        abstract: "Setup deployment variants (alongside Fastlane)"
    )
    
    // --------------
    // MARK: Configuration Properties
    
    @Option(name: .shortAndLong, help: "'ios' or 'android'")
    var platform: String = ""
    
    @Option(name: .shortAndLong, help: "Use a different yaml configuration spec")
    var spec: String = "variants.yml"
    
    @Flag()
    var skipFastlane: Bool = false
    
    @Flag(name: .shortAndLong)
    var verbose = false
    
    mutating func run() throws {
        let logger = Logger(verbose: verbose)
        logger.logSection("$ ", item: "variants setup", color: .ios)

        let detectedPlatform = try PlatformDetector.detect(fromArgument: platform)
        let project = ProjectFactory.from(platform: detectedPlatform)
        try project.setup(spec: spec, skipFastlane: skipFastlane, verbose: verbose)
    }
}
