//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import ArgumentParser

struct Initializer: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Generate spec file - variants.yml"
    )

    // MARK: - Configuration Properties
    
    @Option(name: .shortAndLong, help: "'ios' or 'android'")
    var platform: String = ""
    
    @Flag(name: .shortAndLong)
    var verbose = false
    
    mutating func run() throws {
        let logger = Logger(verbose: verbose)
        logger.logSection("$ ", item: "variants init", color: .ios)

        let detectedPlatform = try PlatformDetector.detect(fromArgument: platform)
        let project = ProjectFactory.from(platform: detectedPlatform)
        try project.initialize(verbose: verbose)
    }
}

