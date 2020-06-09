//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

typealias DoesFileExist = (exists: Bool, path: Path?)

public enum Platform: String {
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
    
    @Param(validation: Validation.allowing(Platform.ios.rawValue, Platform.android.rawValue))
    var platform: String
    
    let logger = Logger.shared
    
    public func execute() throws {
        
        let result = doesTemplateExist()
        guard result.exists, let path = result.path
        else {
            logger.logError("❌: ",
                            item: "Templates folder not found on '/usr/local/lib/variants/templates' or './Templates'")
            exit(1)
        }
    
        logger.logSection("$ ", item: "variants init \(platform)", color: .ios)
        
        do {
            try generateConfig(path: path, platform: Platform(rawValue: platform) ?? .unknown)
        } catch {
            logger.logError("❌: ", item: error.localizedDescription)
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
