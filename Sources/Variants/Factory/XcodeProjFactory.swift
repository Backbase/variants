//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import XcodeProj
import PathKit

struct XcodeProjFactory {
    func modify(_ keyValue: [String: String], in projectPath: Path, target: Target) {
        do {
            
            let project = try XcodeProj(path: projectPath)
            Logger.shared.logInfo("Updating: ", item: projectPath)
            for conf in project.pbxproj.buildConfigurations {
                if
                    let infoList = conf.buildSettings["INFOPLIST_FILE"] as? String,
                    infoList == target.source.info {
                    
                    keyValue.forEach { (key, value) in
                        Logger.shared.logDebug("Item: ", item: "\(key) = \(value)", indentationLevel: 1, color: .purple)
                        conf.buildSettings[key] = value
                    }
                }
            }
            try project.write(path: projectPath)
            Logger.shared.logInfo("🚀 ", item: "Xcode Project modified with success", color: .green)
            
        } catch {
            Logger.shared.logError("❌ ", item: "Unable to edit project '\(projectPath)'")
            exit(1)
        }
    }
}
