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
    
    @Option(name: .shortAndLong, help: "'ios' or 'android'")
    var platform: Platform
    
    @Flag(name: .shortAndLong)
    var verbose = false
    
    mutating func run() throws {
        let logger = Logger(verbose: verbose)
        logger.logSection("$ ", item: "variants init", color: .ios)
        
        guard let path = XCConfigFactory(logLevel: verbose).firstTemplateDirectory() else {
            throw RuntimeError("❌ Templates folder not found in '/usr/local/lib/variants/templates' or './Templates'")
        }

        do {
            try VariantSpecFactory().generateSpec(path: path, platform: platform)
        } catch {
            throw RuntimeError(error.localizedDescription)
        }
    }
}
