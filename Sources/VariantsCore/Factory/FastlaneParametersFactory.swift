//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import Stencil
import PathKit

protocol ParametersFactory {
    func createParametersFile(in file: Path, renderTemplate: String, with parameters: [CustomProperty]) throws
    func createMatchFile(for variant: iOSVariant, configuration: iOSConfiguration) throws
    func render(context: [String: Any], renderTemplate: String) throws -> Data?
    func write(_ data: Data, using parametersFile: Path) throws
}
enum FastlaneParametersFactoryError: Error {
    case templateNotFound
}
class FastlaneParametersFactory: ParametersFactory {
    init(templatePath: Path? = try? TemplateDirectory().path) {
        self.templatePath = templatePath
    }
    
    func createParametersFile(in file: Path, renderTemplate: String, with parameters: [CustomProperty]) throws {
        guard
            let context = context(for: parameters),
            let data = try render(context: context, renderTemplate: renderTemplate)
        else { throw FastlaneParametersFactoryError.templateNotFound}
        try write(data, using: file)
    }
    
    func createMatchFile(for variant: iOSVariant, configuration: iOSConfiguration) throws {
        // Return immediately if folder 'fastlane/' doesn't exist.
        guard StaticPath.Fastlane.baseFolder.exists && StaticPath.Fastlane.baseFolder.isDirectory
        else { return }
        
        // Populate 'fastlane/parameters/match_params.rb' from template
        let parameters: [CustomProperty] = variant.releaseSigning?.customProperties() ?? []
        try? createParametersFile(in: StaticPath.Fastlane.matchParametersFile,
                                  renderTemplate: StaticPath.Template.matchParametersFileName,
                                  with: parameters)
        
        // Populate 'fastlane/Matchfile' from template
        let extensionBundleIDs = configuration.extensions
            .filter { $0.signed }
            .map { $0.makeBundleID(variant: variant, target: configuration.target) }
            .reduce(into: [], { $0.append($1) })
        let appBundleID = [variant.makeBundleID(for: configuration.target)]
        var context: [String: Any] = [
            "export_method": (variant.releaseSigning?.exportMethod ?? .appstore).rawValue,
            "app_identifiers": appBundleID + extensionBundleIDs
        ]
        
        if let matchURL = variant.releaseSigning?.matchURL {
            context["git_url"] = matchURL
        } else {
            Logger.shared.logWarning(item:
                """
                We couldn't add 'git_url' to 'fastlane/Matchfile' as we failed to find a 'matchURL' in your variants spec,
                either in 'ios.signing' or 'ios.variants.\(variant.name).signing'. Please add it manually.
                """
            )
        }
        
        guard let data = try render(context: context, renderTemplate: StaticPath.Template.matchFileName)
        else { return }
        try write(data, using: StaticPath.Fastlane.matchFile)
    }
    
    func render(context: [String: Any], renderTemplate: String) throws -> Data? {
        guard let path = templatePath else { return nil }
        let environment = Environment(loader: FileSystemLoader(paths: [path.absolute()]))
        let rendered = try environment.renderTemplate(name: renderTemplate,
                                                      context: context)
        
        // Replace multiple empty lines by one only
        let lines = rendered.split(whereSeparator: \.isNewline)
        let content = lines.joined(separator: "\n")
        
        return Data(content.utf8)
    }
    
    func write(_ data: Data, using parametersFile: Path) throws {
        let parentFolder = parametersFile.parent()
        if parentFolder.isDirectory, parentFolder.exists {
            
            // Only proceed to write to file if such doesn't yet exist
            // Or does exist and 'isWritable'
            guard !parametersFile.exists
                    || parametersFile.isWritable else {
                throw RuntimeError("'\(parametersFile.abbreviate())' can't be modified, you don't have write permission.")
            }
            
            // Write to file
            try parametersFile.write(data)
        } else {
            throw RuntimeError("'\(parentFolder.abbreviate())' doesn't exist or isn't a directory.")
        }
    }
    
    private func context(for parameters: [CustomProperty]) -> [String: Any]? {
        let fastlaneParameters = parameters.literal()
        let fastlaneEnvVars = parameters.envVars()
        guard !fastlaneParameters.isEmpty || !fastlaneEnvVars.isEmpty else { return nil }
        
        let context = [
            "parameters": fastlaneParameters,
            "env_vars": fastlaneEnvVars
        ]
        return context
    }
    
    private let templatePath: Path?
}

fileprivate extension Sequence where Iterator.Element == CustomProperty {
    func envVars() -> [CustomProperty] {
        return self
            .filter({ $0.destination == .fastlane && $0.isEnvironmentVariable })
            .map { (property) -> CustomProperty in
                return CustomProperty(name: property.name,
                                      value: property.environmentValue,
                                      destination: property.destination)
            }
    }
    
    func literal() -> [CustomProperty] {
        return self
            .filter({ $0.destination == .fastlane && !$0.isEnvironmentVariable })
    }
}
