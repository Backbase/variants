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

    // --------------
    // MARK: Configuration Properties
    
    @Option()
    var platform: Platform
    
    mutating func run() throws {
        
        let result = XCConfigFactory().doesTemplateExist()
        guard result.exists, let path = result.path
        else {
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
    
    private func generateConfig(path: Path, platform: Platform) throws {
        guard path.absolute().exists else {
            throw RuntimeError("Couldn't find template path")
        }
        
        try Bash("cp", arguments: "\(path.absolute())/\(platform.rawValue)/variants-template.yml", "./variants.yml").run()
    }
    
    private func doesTemplateExist() -> DoesFileExist {
        var path: Path?
        var exists = true
        
        let libTemplates = Path("/usr/local/lib/variants/templates")
        let localTemplates = Path("./Templates")
        
        if libTemplates.exists {
            path = libTemplates
        } else if localTemplates.exists {
            path = localTemplates
        } else {
            exists = false
        }
        
        return (exists: exists, path: path)
    }
}
