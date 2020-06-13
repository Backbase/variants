//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import ArgumentParser

struct Initializer: ParsableCommand, VerboseLogger {
    static var configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Generate spec file - variants.yml"
    )
    
    @Option()
    var platform: Platform
    
    mutating func run() throws {
        guard let path = firstTemplateDirectory() else {
            throw RuntimeError("❌ Templates folder not found in '/usr/local/lib/variants/templates' or './Templates'")
        }
    
        Logger.shared.logSection("$ ", item: "variants init \(platform)", color: .ios)
        
        do {
            try generateConfig(path: path, platform: platform)
            Logger.shared.logInfo("📝  ", item: "Variants' spec generated with success at path './variants.yml'", color: .green)
        } catch {
            throw RuntimeError(error.localizedDescription)
        }
    }
    
    // MARK: - Private
    
    private func generateConfig(path: Path, platform: Platform) throws {
        try Bash("cp", arguments: "\(path.absolute())/\(platform.rawValue)/variants-template.yml", "./variants.yml").run()
    }
    
    private func firstTemplateDirectory() -> Path? {
        templateDirectories
            .map(Path.init(stringLiteral:))
            .first(where: \.exists)
    }
    
    // TODO: Maybe extract template directory logic?
    private var templateDirectories: [String] = [
        "/usr/local/lib/variants/templates",
        "./Templates"
    ]
}
