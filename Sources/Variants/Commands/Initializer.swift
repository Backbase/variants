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

        logger.logSection("$ ", item: "variants init \(platform)", color: .ios)

        do {
            try VariantSpecFactory().generateSpec(path: path, platform: platform)
        } catch {
            logger.logError("❌ ", item: error.localizedDescription)
        }
    }
}
