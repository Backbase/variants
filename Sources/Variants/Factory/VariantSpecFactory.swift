//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import SwiftCLI
import PathKit

enum iOSProjectKey: String, CaseIterable {
    case project = "PROJECT"
    case target = "TARGET"
    case appName = "APP_NAME"
    case appBundleID = "APP_BUNDLE_ID"
    case appIcon = "APP_ICON"
    case source = "SOURCE"
    case infoPlist = "INFO_PLIST"
    
    var placeholder: String {
        "{{ "+rawValue+" }}"
    }
}

struct VariantSpecFactory {
    
    /// Generate Variants YAML spec from a template
    /// - Parameters:
    ///   - path: Path to the YAML spec template
    ///   - platform: `Platform` for which the operation is required
    /// - Throws: Exception for any operation that goes wrong.
    func generateSpec(path: Path, platform: Platform) throws {
        guard path.absolute().exists else {
            throw CLI.Error(message: "Couldn't find template path")
        }
        let variantsPath = Path("./variants.yml")
        try Task.run(bash: "cp \(path.absolute())/\(platform.rawValue)/variants-template.yml \(variantsPath)", directory: nil)
        
        if platform == .ios {
            try populateiOSSpec(path: variantsPath)
        }
        
        Logger.shared.logInfo("📝  ", item: "Variants' spec generated with success at path './variants.yml'", color: .green)

    }
    
    /// Automatically populate this spec for `iOS` platform using the `XcodeProjFactory()`
    /// - Parameter path: Path to Variants YAML spec file.
    /// - Throws: Exception for any operation that goes wrong.
    private func populateiOSSpec(path: Path) throws {
        let projectSpecificInformation = XcodeProjFactory().applicationData()
        try projectSpecificInformation.forEach { (key, value) in
            if !value.isEmpty {
                let escapedValue = value.replacingOccurrences(of: "/", with: "\\/")
                try Task.run(bash: "sed -i -e 's/\(key.placeholder)/\(escapedValue)/g' \(path)")
            }
        }

        //
        if projectSpecificInformation.count < iOSProjectKey.allCases.count {
            Logger.shared.logWarning("⚠️  ", item: "We were unable to populate './variants.yml' automatically. Please open the file and remove the placeholders.")
        }
        
        // Remove remaining '*-e' file after `sed` in-file replacemnt
        try? Task.run(bash: "rm -rf \(path)-e")
    }
}
