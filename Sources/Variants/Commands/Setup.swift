//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import SwiftCLI
import PathKit
import Yams

public protocol Setup: YamlParser {
    var name: String { get }
    var shortDescription: String { get }
    var platform: Platform { get set }
    
    func decode(configuration: String) -> Configuration?
}

extension Setup {
    public func decode(configuration: String) -> Configuration? {
        do {
            return try extractConfiguration(from: configuration, platform: platform)
        } catch {
            log(error.localizedDescription)
        }
        return nil
    }
}

public class SetupDefault: Command, VerboseLogger, Setup {
    
    // --------------
    // MARK: Command information
    
    public var name: String = "setup"
    public var shortDescription: String = "Default description"
    
    // --------------
    // MARK: Configuration Properties
    
    @Key("-c", "--config", description: "Use a yaml configuration file")
    var configuration: String?
    
    @Flag("-f", "--include-fastlane", description: "Should setup fastlane")
    var includeFastlane: Bool
    
    public var platform: Platform = .unknown
    
    public func execute() throws {
        guard let configurationData = try loadConfiguration(configuration) else {
            throw CLI.Error(message: "Unable to proceed creating build variants")
        }
        
        scanVariants(with: configurationData)
        setupFastlane(includeFastlane)
    }
    
    public func createVariants(for variants: [Variant]?) {}
    
    // --------------
    // MARK: Private methods
    
    private func scanVariants(with configuration: Configuration) {
        var variants: [Variant]?
        switch platform {
        case .ios:
            variants = configuration.ios?.variants
        case .android:
            variants = configuration.android?.variants
        default:
            break
        }
        
        configuration.ios?.targets.map { (target: $0, pbx: configuration.ios?.pbxproj) }.forEach({ (result) in
            touchConfig(with: result.target.value, variants: variants, pbxproj: result.pbx)
        })
    }
    
    private func setupFastlane(_ include: Bool) {
        if include {
            log("Setting up Fastlane", indentationLevel: 1)
        } else {
            log("Skipping Fastlane setup", indentationLevel: 1)
        }
    }
    
    // MARK: - Revamp
    private func touchConfig(with target: Target, variants: [Variant]?, pbxproj: String?) {
        log("Check if mobile-variants.xcconfig exist")
        
        guard let parentString = configuration else  { return }
        let configPath = Path(parentString).absolute().parent()
        
        let configString = target.source.config
        
        let xcodeConfigFolder = Path("\(configPath)/\(configString)")
        guard xcodeConfigFolder.isDirectory else {
            log("Source isn't a folder or doesn't exist", indentationLevel: 1)
            log("\(xcodeConfigFolder.absolute().description)")
            return
        }

        let xcodeConfigPath = Path("\(xcodeConfigFolder.absolute().description)/mobile-variants.xcconfig")
        if !xcodeConfigPath.isFile {
            log("mobile-variants.xcconfig already exist, cleaning up", indentationLevel: 1)
        }
        
        write("", toFile: xcodeConfigPath, force: true)
        log("Created file: 'mobile-variants.xcconfig' at \(xcodeConfigFolder.absolute().description)",
            indentationLevel: 1)
        
        populateConfig(with: target, configFile: xcodeConfigPath, variants: variants)
        
        /*
         * INFO.plist
         */
        let infoPath = target.source.info
        let infoPlistPath = Path("\(configPath)/\(infoPath)")
        
        updateInfoPlist(with: target, configFile: infoPlistPath, variants: variants)
        
        /*
         * PBXPROJ
         */
        guard let pbxString = pbxproj else { return }
        convertPBXToJSON("\(configPath)/\(pbxString)")
    }
    
    private func populateConfig(with target: Target, configFile: Path, variants: [Variant]?) {
        guard let variant = variants?.first else {
            log("Variants not specified", color: .red)
            return
        }
        
        log("Populating xcconfig")
        
        variant.getDefaultValues(for: target).forEach { (key, value) in
            let stringContent = "\(key) = \(value)"
            log("\(stringContent) \n", indentationLevel: 2, color: .ios)
            
            let (success, file) = write(stringContent, toFile: configFile, force: false)
        }
    }
    
    private func updateInfoPlist(with target: Target, configFile: Path, variants: [Variant]?) {
        
        do {
            try Task.run(bash: "plutil -replace CFBundleVersion -string '$(MV_VERSION_NUMBER)' \(configFile.absolute().description)")
            
            try Task.run(bash: "plutil -replace CFBundleShortVersionString -string '$(MV_VERSION_NAME)' \(configFile.absolute().description)")
            
            try Task.run(bash: "plutil -replace CFBundleName -string '$(MV_APP_NAME)' \(configFile.absolute().description)")
            
            try Task.run(bash: "plutil -replace CFBundleExecutable -string '$(MV_APP_NAME)' \(configFile.absolute().description)")
            
            try Task.run(bash: "plutil -replace CFBundleIdentifier -string '$(MV_BUNDLE_ID)' \(configFile.absolute().description)")
            
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    private func convertPBXToJSON(_ config: String) {
        do {
            print("Convert project.pbxproj to JSON")
            try Task.run(bash: "plutil -convert json \(config)")
        } catch {}
    }
    
    private func write(_ stringContent: String, toFile file: Path, force: Bool) -> (Bool, Path?) {
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
}

extension SetupDefault {
    private func loadConfiguration(_ path: String?) throws -> Configuration? {
        guard let path = path else {
            throw CLI.Error(message: "Error: Use '-c' to specify the configuration file")
        }
        
        let configurationPath = Path(path)
        guard !configurationPath.isDirectory else {
            throw CLI.Error(message: "Error: \(configurationPath) is a directory path")
        }
        
        let configuration = decode(configuration: path)
        return configuration
    }
}


extension String {
    func appendLine(to file: Path) throws {
        try (self + "\n").appendToURL(fileURL: file.url)
    }
    
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
