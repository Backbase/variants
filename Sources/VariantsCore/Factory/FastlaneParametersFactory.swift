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
    func render(parameters: [CustomProperty], renderTemplate: String) throws -> Data?
    func write(_ data: Data, using parametersFile: Path) throws
}

class FastlaneParametersFactory: ParametersFactory {
    init(templatePath: Path? = try? TemplateDirectory().path) {
        self.templatePath = templatePath
    }
    
    func createParametersFile(in file: Path, renderTemplate: String, with parameters: [CustomProperty]) throws {
        guard let data = try render(parameters: parameters, renderTemplate: renderTemplate) else { return }
        try write(data, using: file)
    }
    
    func render(parameters: [CustomProperty], renderTemplate: String) throws -> Data? {
        let fastlaneParameters = parameters.literal()
        let fastlaneEnvVars = parameters.envVars()
        guard !fastlaneParameters.isEmpty || !fastlaneEnvVars.isEmpty else { return nil }
        
        let context = [
            "parameters": fastlaneParameters,
            "env_vars": fastlaneEnvVars
        ]

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
                throw TemplateDoesNotExist(templateNames: [parentFolder.string])
            }
            
            // Write to file
            try parametersFile.write(data)
        } else {
            throw TemplateDoesNotExist(templateNames: [parentFolder.string])
        }
    }
    
    private let templatePath: Path?
}

fileprivate extension Sequence where Iterator.Element == CustomProperty {
    func envVars() -> [CustomProperty] {
        return self
            .filter({ $0.destination == .fastlane && $0.processForEnvironment().isEnvVar })
            .map { (property) -> CustomProperty in
                let processed = property.processForEnvironment()
                if processed.isEnvVar {
                    return CustomProperty(name: property.name,
                                          value: processed.string,
                                          destination: property.destination)
                }
                return property
            }
    }
    
    func literal() -> [CustomProperty] {
        return self
            .filter({ $0.destination == .fastlane && !$0.processForEnvironment().isEnvVar })
    }
}
