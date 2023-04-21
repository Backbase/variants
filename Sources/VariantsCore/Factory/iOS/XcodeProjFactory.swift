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
    private let logger: Logger
    
    init(logLegel: Bool = false) {
        logger = Logger(verbose: logLegel)
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
    func add(_ files: [Path], toProject projectPath: Path, sourceRoot: Path, target: NamedTarget) {
        do {
            let project = try XcodeProj(path: projectPath)
            let variantsGroup = try createVarientsGroup(for: project, path: projectPath, sourceRoot: sourceRoot, target: target)
            for file in files {
                try add(
                    file: file,
                    to: project,
                    path: projectPath,
                    variantsGroup: variantsGroup,
                    sourceRoot: sourceRoot,
                    target: target
                )
            }
            try project.write(path: projectPath)
        } catch {
            dump(error)
            logger.logFatal("❌ ", item: "Unable to add files to Xcode project '\(projectPath)'")
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
                          target: NamedTarget,
                          autoSave: Bool = false) {
        do {
            for conf in xcodeProject.pbxproj.buildConfigurations {
                if
                    let infoList = conf.buildSettings["INFOPLIST_FILE"] as? String,
                    infoList == target.value.source.info {
                    conf.baseConfiguration = fileReference
                }
            }
            if autoSave { try xcodeProject.write(path: path) }
            logger.logInfo("✅ ", item: "Changed baseConfiguration of target '\(target.key)'",
                           color: .green)
        } catch {
            logger.logFatal("❌ ", item: "Unable to edit baseConfiguration for target '\(target.key)'")
        }
    }
    
    /// Modify value directly in `.xcodeproj/project.pbxproj`
    /// - Parameters:
    ///   - keyValue: Key/value pair to be modified
    ///   - projectPath: Path to Xcode project
    ///   - target: iOSTarget on which the `buildSettings` should be changed.
    ///   - asTestSettings: If true, add configuraiton to test/non-host targets.
    ///   - silent: Flag to determine if final logs are necessary
    func modify(_ keyValue: [String: String],
                in projectPath: Path,
                target: iOSTarget,
                asTestSettings: Bool = false,
                silent: Bool = false) {
        do {
            let project = try XcodeProj(path: projectPath)
            logger.logInfo("Updating: ", item: projectPath)
            
            let matchingKey = asTestSettings ? target.testTarget : target.source.info
            project.pbxproj.buildConfigurations
                .filter({ ($0.buildSettings["INFOPLIST_FILE"] as? String)?.contains(matchingKey) ?? false })
                .forEach { conf in
                    keyValue.forEach { (key, value) in
                        Logger.shared.logDebug("Item: ", item: "\(key) = \(value)",
                                               indentationLevel: 1, color: .purple)
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
    
    private func createVarientsGroup(
        for project: XcodeProj,
        path: Path,
        sourceRoot: Path,
        target: NamedTarget
    ) throws -> PBXGroup? {
        let variantsGroupPath = Path("\(path)/Variants")
        let rootGroup = project.pbxproj.groups.first(where: { $0.path == sourceRoot.lastComponent })
        try rootGroup?.addGroup(named: variantsGroupPath.lastComponent)
        let variantsGroup = rootGroup?.group(named: variantsGroupPath.lastComponent)
        return variantsGroup
    }
    
    // swiftlint:disable function_parameter_count
    private func add(
        file: Path,
        to project: XcodeProj,
        path: Path,
        variantsGroup: PBXGroup?,
        sourceRoot: Path,
        target: NamedTarget
    ) throws {
        guard let pbxTarget = project.pbxproj.targets(named: target.key).first
        else {
            logger.logFatal("❌ ", item: "Could not add files to Xcode project - Target '\(target.key)' not found.")
            return
        }
        
        let fileRef = try variantsGroup?.addFile(
            at: file,
            sourceTree: .group,
            sourceRoot: sourceRoot,
            validatePresence: true
        )
        
        let fileElement = PBXFileElement(
            sourceTree: .group,
            path: file.description,
            name: file.lastComponent
        )
        let buildFile = PBXBuildFile(file: fileElement)
        let sourceBuildPhase = try pbxTarget.sourcesBuildPhase()
        sourceBuildPhase?.files?.append(buildFile)
        
        /*
         * If .xcconfig, set baseConfigurationReference to it
         */
        if file.extension == "xcconfig", let fileReference = fileRef {
            changeBaseConfig(fileReference, in: project, path: path,
                             target: target, autoSave: true)
        }
    }
    // swiftlint:enable function_parameter_count
}
