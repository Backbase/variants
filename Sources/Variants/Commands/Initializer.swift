//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

public enum Platform: String, ConvertibleFromString {
    case ios
    case android
    case unknown
}

final class Initializer: Command, VerboseLogger {
    // --------------
    // MARK: Command information
    
    let name: String = "init"
    let shortDescription: String = "Generate specs file - variants.yml"
    
    // --------------
    // MARK: Configuration Properties
    
    @Param(validation: Validation.allowing(Platform.ios, Platform.android))
    var platform: Platform
    
    let logger = Logger.shared
    
    public func execute() throws {
        
        let result = XCConfigFactory().doesTemplateExist()
        guard result.exists, let path = result.path
        else {
            logger.logFatal("❌ ", item: "Templates folder not found on '/usr/local/lib/variants/templates' or './Templates'")
            return
        }
        logger.logSection("$ ", item: "variants init \(platform)", color: platform.color)
        
        do {
            try generateConfig(path: path, platform: platform)
            Logger.shared.logInfo("📝  ", item: "Variants' spec generated with success at path './variants.yml'", color: .green)
        } catch {
            logger.logError("❌ ", item: error.localizedDescription)
        }
    }
    
    private func generateConfig(path: Path, platform: Platform) throws {
        guard path.absolute().exists else {
            throw CLI.Error(message: "Couldn't find template path")
        }
        try Task.run(bash: "cp \(path.absolute())/\(platform.rawValue)/variants-template.yml ./variants.yml", directory: nil)
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
