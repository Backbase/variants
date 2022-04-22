//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Oleg Baidalka on 31.03.2022.
//

import Foundation
import ArgumentParser
import PathKit
import SwiftUI

public struct List: ParsableCommand {
    public init() {}
    
    public static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all variants"
    )
    
    // MARK: - Configuration Properties
        
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
        let detectedPlatform = try PlatformDetector.detect(fromArgument: platform)
        let project = ProjectFactory.from(platform: detectedPlatform, logger: logger)
        let variants = try project.list(spec: spec)

        let output = Logger(verbose: true)
        variants.forEach { $0.print(logger: output, project: project) }
    }
}

fileprivate extension Variant {
    func print(logger: Logger, project: Project) {
        if project.isCurrent(variant: self) {
            logger.log(item: "* \(title)", indentationLevel: 0, color: .green, logLevel: .verbose)
        } else {
            logger.log(item: "  \(title)", indentationLevel: 0, color: .neutral, logLevel: .verbose)
        }
    }
}
