//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

// swiftlint:disable file_length

import Foundation
import XcodeProj
import PathKit

struct XcodeProjFactory {
    enum BuildConfigType: String, CaseIterable {
        case debug, release
    }

    private let logger: Logger
    
    init(enableVerboseLog: Bool = false) {
        logger = Logger(verbose: enableVerboseLog)
    }
    
    /// Scan the working directory for a Xcode project
    /// - Returns: Optional Path of the `.xcodeproj` folder
    func projectPath() -> Path? {
        return Path.glob("*.xcodeproj").first(where: \.exists)
    }
    
    /// Returns the application's target data used in `variants.yml`
    /// - Returns: Dictionary of [`iOSProjectKey`: `String`]
    func applicationData() -> [iOSProjectKey: String] {
        var applicationData: [iOSProjectKey: String] = [:]
        guard let projectPath = projectPath() else {
            Logger.shared.logFatal(item: "Could not find .xcodeproj in working directory")
            return applicationData
        }
        
        let projectName = projectPath.lastComponentWithoutExtension
        applicationData[iOSProjectKey.project] = projectName
        
        do {
            let project = try XcodeProj(path: projectPath)
    
            // Use the first target whose type is `application`
            // Multiple application targets aren't supported at the moment.
            if let target = project.pbxproj.nativeTargets
                .first(where: { $0.productType == PBXProductType.application }) {
                
                applicationData[iOSProjectKey.target] = target.name
                
                // Use first `buildSettings` containing entry for `INFOPLIST_FILE`
                if let buildSettings = target.buildConfigurationList?.buildConfigurations
                    .first(where: { $0.buildSettings.contains { (key, _) -> Bool in
                        key == "INFOPLIST_FILE"
                } }).map(\.buildSettings) {
                    
                    // Use first `buildSettings` containing entry for `INFOPLIST_FILE`
                    if let infoPlist = buildSettings["INFOPLIST_FILE"] as? String {
                        applicationData[iOSProjectKey.infoPlist] = infoPlist
                        
                        // Due to the nature of our 'Bash' helper, we have to run one command at a time,
                        // not allowing us to pipe commands as `plutil ... | sed ...`.
                        // This requires us to write the output of `plutil` to a temporary file and
                        // use the content of this file as input for `sed`.
                        if let appNameTag = try? Bash("plutil", arguments: "-extract",
                                                      "CFBundleDisplayName",
                                                      "xml1", "-o", "-", "\(infoPlist)").capture(),
                           // Create temporary file
                           let temporaryFile = try? Bash("mktemp").capture() {
                            
                            // Write the output of `plutil` to temporary file
                            try appNameTag.write(to: URL(fileURLWithPath: temporaryFile),
                                                 atomically: true, encoding: .utf8)
                            
                            if let appName = try? Bash("sed", arguments: "-n",
                                                       "s/.*<string>\\(.*\\)<\\/string>.*/\\1/p",
                                                       temporaryFile).capture(),
                               !appName.isEmpty {
                                
                                // Assign appName to `applicationData` dictionary,
                                // trimming whitespaces and new lines
                                applicationData[iOSProjectKey.appName] = appName
                                    .trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                            }
                        }
                        let sourcePath = infoPlist.split(separator: "/").dropLast().joined(separator: "/")
                        applicationData[iOSProjectKey.source] = sourcePath
                    }
                    
                    if let bundleId = buildSettings["PRODUCT_BUNDLE_IDENTIFIER"] as? String,
                       !bundleId.isEmpty {
                        applicationData[iOSProjectKey.appBundleID] = bundleId
                    }
                    
                    if let appIcon = buildSettings["ASSETCATALOG_COMPILER_APPICON_NAME"] as? String,
                       !appIcon.isEmpty {
                        applicationData[iOSProjectKey.appIcon] = appIcon
                    }
                }
            }
        } catch {
            // Do nothing, simply return the empty dictionary
            // The user will be forced to update variants' spec by hand.
        }
        return applicationData
    }
    
    /// Add files to Xcode project
    /// - Parameters:
    ///   - files: List of file paths
    ///   - projectPath: Path to `.xcodeproj`
    ///   - sourceRoot: Path to source root group the files will be added to
    ///   - target: Named target `(key: String, value: Target) ` these files will be added to
    func add(_ files: [Path], toProject projectPath: Path, sourceRoot: Path, target: iOSTarget) {
        do {
            let project = try XcodeProj(path: projectPath)
            for file in files {
                try add(file: file, project: project, projectPath: projectPath, sourceRoot: sourceRoot, target: target)
            }
            try project.write(path: projectPath)
        } catch {
            logger.logFatal("❌ ", item: "Unable to add files to Xcode project '\(projectPath)', error: '\(error.localizedDescription)'")
        }
    }

    /// Change Xcode project's base configuration.
    /// - Parameters:
    ///   - fileReference: File reference of the `.xcconfig` file
    ///   - xcodeProject: Reference to the `XcodeProj` instance
    ///   - path: Path to `.xcodeproj` for auto saving purposes
    ///   - target: NamedTarget. Used to ensure the change occurs in the correct target.
    ///   - autoSave: Flag if the project should be saved after the changes
    func changeBaseConfig(_ fileReference: PBXFileReference,
                          in xcodeProject: XcodeProj,
                          path: Path,
                          target: iOSTarget,
                          autoSave: Bool = false) {
        do {
            let isUsingCocoapodsWorkspace = isCocoapodsWorkspace(
                configurations: xcodeProject.pbxproj.buildConfigurations)

            for conf in xcodeProject.pbxproj.buildConfigurations {
                if isUsingCocoapodsWorkspace {
                    let confName = conf.baseConfiguration?.name?.lowercased()
                    guard confName?.contains("pods") == false else { continue }
                    conf.baseConfiguration = fileReference
                } else {
                    guard conf.infoPlistFile == target.source.info else { continue }
                    conf.baseConfiguration = fileReference
                }
            }
            
            if autoSave {
                try xcodeProject.write(path: path)
            }
            
            logger.logInfo("✅ ", item: "Changed baseConfiguration of target '\(target.name)'",
                           color: .green)
        } catch {
            logger.logFatal("❌ ", item: "Unable to edit baseConfiguration for target '\(target.name)'")
        }
    }

    private func isCocoapodsWorkspace(configurations: [XCBuildConfiguration]) -> Bool {
        for conf in configurations {
            // swiftlint:disable:next for_where
            if conf.baseConfiguration?.name?.lowercased().contains("pods") == true {
                return true
            }
        }
        return false
    }

    /// Modify value directly in `.xcodeproj/project.pbxproj`
    /// - Parameters:
    ///   - keyValue: Key/value pair to be modified
    ///   - projectPath: Path to Xcode project
    ///   - targetName: Name of the target on which the `buildSettings` should be changed.
    ///   - silent: Flag to determine if final logs are necessary
    func modify(_ keyValue: [String: String],
                in projectPath: Path,
                targetName: String,
                configurationTypes: [BuildConfigType] = BuildConfigType.allCases,
                silent: Bool = false) {
        do {
            let project = try XcodeProj(path: projectPath)
            let configTypeNames = configurationTypes.map { $0.rawValue.lowercased() }
            logger.logInfo("Updating: ", item: projectPath)

            project.pbxproj.buildConfigurations
                .filter({ $0.infoPlistFile?.contains(targetName) ?? false })
                .filter({ configTypeNames.contains($0.name.lowercased()) })
                .forEach { conf in
                    logger.logDebug(
                        "Build configuration type: ", item: conf.name, indentationLevel: 1, color: .blue)
                    keyValue.forEach { (key, value) in
                        logger.logDebug(
                            "Item: ", item: "\(key) = \(value)", indentationLevel: 2, color: .purple)
                        conf.buildSettings[key] = value
                    }
                }
            try project.write(path: projectPath)
            if !silent {
                logger.logInfo("⚙️  ", item: "Xcode Project modified with success", color: .green)
            }
            
        } catch {
            logger.logFatal("❌ ", item: "Unable to edit Xcode project '\(projectPath)'")
        }
    }
}

private extension XcodeProjFactory {
    private func getOrCreateVariantsGroup(
        for project: XcodeProj,
        path: Path,
        target: iOSTarget
    ) throws -> PBXGroup? {
        let groupName = "Variants"
        let currentVariantsGroup = project.pbxproj.groups.first(where: { $0.path == groupName || $0.name == groupName })

        guard currentVariantsGroup == nil else { return currentVariantsGroup }
        let sourceGroup = project.pbxproj.groups.first(where: { $0.path == target.name })
        return try sourceGroup?.addGroup(named: groupName).first
    }

    private func add(
        file: Path,
        project: XcodeProj,
        projectPath: Path,
        sourceRoot: Path,
        target: iOSTarget
    ) throws {
        guard let variantsGroup = try getOrCreateVariantsGroup(for: project, path: projectPath, target: target)
        else {
            return logger.logFatal("❌ ", item: "Failed to generate Variants group at provided target name")
        }
        guard let pbxTarget = project.pbxproj.targets(named: target.name).first
        else {
            return logger.logFatal("❌ ", item: "Could not add files to Xcode project - Target '\(target.name)' not found.")
        }

        let fileReference = try variantsGroup.addFile(
            at: file,
            sourceTree: .group,
            sourceRoot: sourceRoot,
            validatePresence: true
        )

        switch file.extension {
        // .swift files must be added to the compile sources build phase
        case "swift":
            let sourcesBuildPhase = try? pbxTarget.sourcesBuildPhase()
            _  = try sourcesBuildPhase?.add(file: fileReference)

        // .xcconfig is set to the project's base config
        case "xcconfig":
            changeBaseConfig(fileReference, in: project, path: projectPath, target: target, autoSave: true)

        // Unsupported file extension
        default:
            break
        }
    }
}

private extension XCBuildConfiguration {
    var infoPlistFile: String? {
        buildSettings["INFO_PLIST"] as? String
    }
}

// swiftlint:enable file_length
