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
    case testTarget = "TEST_TARGET"
    case appIcon = "APP_ICON"
    case source = "SOURCE"
    case infoPlist = "INFO_PLIST"
    
    var placeholder: String {
        "{{ "+rawValue+" }}"
    }
    
    var ymlKeyPath: String {
        switch self {
        case .project:
            return "ios.xcodeproj"
        case .target:
            return "ios.targets.fooTarget"
        case .appName:
            return "ios.targets.fooTarget.name"
        case .appBundleID:
            return "ios.targets.fooTarget.bundle_id"
        case .testTarget:
            return "ios.targets.fooTarget.test_target"
        case .appIcon:
            return "ios.targets.fooTarget.app_icon"
        case .source:
            return "ios.targets.fooTarget.source.path"
        case .infoPlist:
            return "ios.targets.fooTarget.source.info"
        }
    }
}

class SpecHelper {
    init(
        templatePath: Path,
        userInput: UserInput
    ) {
        self.templatePath = templatePath
        self.userInput = userInput
    }

    /// Generate Variants YAML spec from a template
    /// - Parameters:
    ///   - path: Path to the YAML spec template
    ///   - userInputEnabled: Bool. Defines it should use interactive shell.
    /// - Throws: Exception for any operation that goes wrong.
    func generate(from path: Path, userInputEnabled: Bool = true) throws {
        guard path.absolute().exists else {
            throw RuntimeError("Couldn't find template path")
        }

        if variantsPath.exists {
            if userInputEnabled && !userInput.doesUserGrantPermissionToOverrideSpec() {
                shouldPopulateSpec = false
                return
            } else {
                try variantsPath.delete()
            }
        }
        
        // TODO: Maybe look for different path library?
        // It's weird that PathKit does not offer an API to merge two paths.
        // Also seems like the repo is no longer maintained.
        let sourcePath = Path(components: [path.absolute().string, templatePath.string])
        try sourcePath.copy(variantsPath)

        Logger.shared.logInfo("📝  ", item: "Variants' spec generated with success at path '\(variantsPath)'", color: .green)
    }

    var shouldPopulateSpec: Bool = true
    let userInput: UserInput
    let variantsPath = Path("./variants.yml")
    let templatePath: Path
}

// MARK: - iOS

class iOSSpecHelper: SpecHelper {
    override func generate(from path: Path, userInputEnabled: Bool = true) throws {
        try super.generate(from: path, userInputEnabled: userInputEnabled)
        // TODO: The log step was after populate. Are we okay with this change?
        if shouldPopulateSpec {
            try populateiOSSpec()
        }
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

        if projectSpecificInformation.isEmpty {
            Logger.shared.logWarning("⚠️  ", item: """
                We were unable to populate './variants.yml' automatically.
                Please open the file and remove the placeholder values.
                i.e.: '{{ VALUE }}'
                """
            )
        } else if projectSpecificInformation.count < iOSProjectKey.allCases.count {
            var warningMessage = """
                We were unable to populate the following fields in the './variants.yml' spec:


                """
            
            iOSProjectKey.allCases
                .filter { !projectSpecificInformation.keys.contains($0) }
                .forEach { projectKey in
                    var ymlKeyPath = projectKey.ymlKeyPath
                    if let targetName = projectSpecificInformation[.target] {
                        ymlKeyPath = ymlKeyPath.replacingOccurrences(of: "fooTarget", with: targetName)
                    }
                    warningMessage.appendLine("    * "+ymlKeyPath)
                }
            
            warningMessage.appendLine("\nPlease replace their placeholders manually.")
            
            Logger.shared.logWarning("⚠️  ", item: warningMessage)
        }

        // Remove remaining '*-e' file after `sed` in-file replacemnt
        try? Bash("rm", arguments: "-rf", "\(variantsPath)-e").run()
    }
}

// MARK: - Android

class AndroidSpecHelper: SpecHelper {}
