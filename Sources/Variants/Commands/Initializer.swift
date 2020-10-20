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
    
    // --------------
    // MARK: Configuration Properties
    
    @Argument(help: "'ios' or 'android'")
    var platform: Platform
    
    @Flag(name: .shortAndLong, help: "Is verbose")
    var verbose = false
    
    mutating func run() throws {
        guard let path = XCConfigFactory(logLevel: verbose).firstTemplateDirectory() else {
            throw RuntimeError("❌ Templates folder not found in '/usr/local/lib/variants/templates' or './Templates'")
        }

        let logger = Logger(verbose: verbose)
        
        logger.logSection("$ ", item: "variants init \(platform)", color: .ios)

        do {
            try generateConfig(path: path, platform: .ios)
            logger.logInfo("📝  ", item: "Variants' spec generated with success at path './variants.yml'", color: .green)
        } catch {
            throw RuntimeError(error.localizedDescription)
        }
    }
    
    // MARK: - Private
    
    private func generateConfig(path: Path, platform: Platform) throws {
        try Bash("cp", arguments: "\(path.absolute())/\(platform.rawValue)/variants-template.yml", "./variants.yml").run()
    }
}
