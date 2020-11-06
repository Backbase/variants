//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit

// swiftlint:disable type_name

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

class SpecHelper {
    init(templatePath: Path) {
        self.templatePath = templatePath
    }

    /// Generate Variants YAML spec from a template
    /// - Parameters:
    ///   - path: Path to the YAML spec template
    /// - Throws: Exception for any operation that goes wrong.
    func generate(from path: Path) throws {
        guard path.absolute().exists else {
            throw RuntimeError("Couldn't find template path")
        }

        // TODO: Maybe look for different path library?
        // It's weird that PathKit does not offer an API to merge two paths.
        // Also seems like the repo is no longer maintained.
        let sourcePath = Path(components: [path.absolute().string, templatePath.string])
        try sourcePath.copy(variantsPath)

        Logger.shared.logInfo("📝  ", item: "Variants' spec generated with success at path '\(variantsPath)'", color: .green)
    }

    let variantsPath = Path("./variants.yml")
    let templatePath: Path
}

// MARK: - iOS

class iOSSpecHelper: SpecHelper {
    override func generate(from path: Path) throws {
        try super.generate(from: path)
        // TODO: The log step was after populate. Are we okay with this change?
        try populateiOSSpec()
    }

    /// Automatically populate this spec for `iOS` platform using the `XcodeProjFactory()`
    /// - Parameter path: Path to Variants YAML spec file.
    /// - Throws: Exception for any operation that goes wrong.
    private func populateiOSSpec() throws {
        let projectSpecificInformation = XcodeProjFactory().applicationData()

        try projectSpecificInformation
            .filter { (_, value) in !value.isEmpty }
            .forEach { (key, value) in
                let escapedValue = value.replacingOccurrences(of: "/", with: "\\/")
                try Bash("sed", arguments: "-i", "-e", "s/\(key.placeholder)/\(escapedValue)/g", "\(variantsPath)").run()
        }

        if projectSpecificInformation.count < iOSProjectKey.allCases.count {
            Logger.shared.logWarning("⚠️  ", item: """
                We were unable to populate './variants.yml' automatically.
                Please open the file and remove the placeholders.
                """
            )
        }

        // Remove remaining '*-e' file after `sed` in-file replacemnt
        try? Bash("rm", arguments: "-rf", "\(variantsPath)-e").run()
    }
}

// MARK: - Android

class AndroidSpecHelper: SpecHelper {}
