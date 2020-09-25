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
    func add(_ files: [Path], toProject projectPath: Path, sourceRoot: Path, target: NamedTarget) {
        let variantsGroupPath = Path("\(projectPath)/Variants")
        
        do {
            let project = try XcodeProj(path: projectPath)
            guard let pbxTarget = project.pbxproj.targets(named: target.key).first
            else {
                Logger.shared.logFatal("❌ ", item: "Could not add files to Xcode project - Target '\(target.key)' not found.")
                return
            }
        
            let rootGroup = project.pbxproj.groups.first(where: { $0.path == sourceRoot.lastComponent })
            try rootGroup?.addGroup(named: variantsGroupPath.lastComponent)
            let variantsGroup = rootGroup?.group(named: variantsGroupPath.lastComponent)
            
            try files.forEach { file in
                let fileRef = try variantsGroup?.addFile(at: file,
                                                         sourceTree: .group,
                                                         sourceRoot: sourceRoot,
                                                         validatePresence: true)
                
                let fileElement = PBXFileElement(sourceTree: .group, path: file.description, name: file.lastComponent)
                let buildFile = PBXBuildFile(file: fileElement)
                let sourceBuildPhase = try pbxTarget.sourcesBuildPhase()
                sourceBuildPhase?.files?.append(buildFile)
                
                /*
                 * If .xcconfig, set baseConfigurationReference to it
                 */
                if file.lastComponent.contains(".xcconfig"), let fileReference = fileRef {
                    changeBaseConfig(fileReference, in: project, path: projectPath, target: target)
                }
            }
            try project.write(path: projectPath)
        } catch {
            dump(error)
            Logger.shared.logFatal("❌ ", item: "Unable to add files to Xcode project '\(projectPath)'")
        }
    }
    
    func changeBaseConfig(_ fileReference: PBXFileReference, in xcodeProject: XcodeProj, path: Path, target: NamedTarget, autoSave: Bool = false) {
        do {
            for conf in xcodeProject.pbxproj.buildConfigurations {
                if
                    let infoList = conf.buildSettings["INFOPLIST_FILE"] as? String,
                    infoList == target.value.source.info {
                    conf.baseConfiguration = fileReference
                }
            }
            if autoSave { try xcodeProject.write(path: path) }
            Logger.shared.logInfo("✅ ", item: "Changed baseConfiguration of target '\(target.key)'", color: .green)
        } catch {
            Logger.shared.logFatal("❌ ", item: "Unable to edit baseConfiguration for target '\(target.key)'")
        }
    }
    
    func modify(_ keyValue: [String: String], in projectPath: Path, target: iOSTarget, silent: Bool = false) {
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
            if !silent {
                Logger.shared.logInfo("⚙️  ", item: "Xcode Project modified with success", color: .green)
            }
            
        } catch {
            Logger.shared.logFatal("❌ ", item: "Unable to edit Xcode project '\(projectPath)'")
        }
    }
}
