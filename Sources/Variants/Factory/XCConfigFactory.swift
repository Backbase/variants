//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import SwiftCLI

struct XCConfigFactory {
    func write(_ stringContent: String, toFile file: Path, force: Bool) -> (Bool, Path?) {
        do {
            if force {
                try stringContent.write(toFile: file.absolute().description,
                                        atomically: false,
                                        encoding: .utf8)
            } else {
                try stringContent.appendLine(to: file)
            }
            return (true, file)
        } catch {
            return (false, nil)
        }
    }
    
    func writeJSON<T>(_ encodableObject: T, toFile file: Path) -> (Bool, Path?) where T : Encodable {
        let encoder = JSONEncoder()
        if #available(OSX 10.15, *) {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        } else {
            encoder.outputFormatting = .prettyPrinted
        }
        
        do {
            try Task.run(bash: "touch \(file.absolute().description)")
            
            let encoded = try encoder.encode(encodableObject)
            guard let encodedJSONString = String(data: encoded, encoding: .utf8) else { return (false, nil) }
            try encodedJSONString.write(toFile: file.absolute().description, atomically: true, encoding: .utf8)
            
            return (true, file)
            
        } catch {
            return (false, nil)
        }
    }
    
    func populateConfig(with target: Target, configFile: Path, variants: [Variant]?) {
        guard let variant = variants?.first else {
            Logger.shared.logError("❌: ", item: "Variants not specified", color: .red)
            return
        }
        
        Logger.shared.logDebug(item: "Populating .xcconfig")
        variant.getDefaultValues(for: target).forEach { (key, value) in
            let stringContent = "\(key) = \(value)"
            Logger.shared.logDebug("Item: ", item: stringContent)
            
            let (success, file) = write(stringContent, toFile: configFile, force: false)
        }
    }
    
    // MARK: - Convert method
    
    func convertPBXToJSON(_ config: Path) {
        do {
            Logger.shared.logDebug(item: "Converting project.pbxproj to JSON")
            try Task.run(bash: "plutil -convert json \(config.absolute().description)")
        } catch {
            Logger.shared.logError("❌: ", item: error.localizedDescription)
        }
    }
}
