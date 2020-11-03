//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import Stencil
import PathKit

let fastlaneParametersTemplateFileName = "variants_params_template.rb"

class FastlaneParametersFactory {
    init(templatePath: Path = try! TemplateDirectory().path) {
        self.templatePath = templatePath
    }
    
    func createParametersFile(in folder: Path, with parameters: [CustomProperty]) throws {
        guard let data = try render(parameters: parameters) else { return }
        try write(data, using: folder)
    }
    
    func render(parameters: [CustomProperty]) throws -> Data? {
        let context = [
          "parameters": parameters
        ]

        let environment = Environment(loader: FileSystemLoader(paths: [templatePath.absolute()]))
        let rendered = try environment.renderTemplate(name: fastlaneParametersTemplateFileName,
                                                      context: context)
        
        // Replace multiple empty lines by one only
        let lines = rendered.split(whereSeparator: \.isNewline)
        let content = lines.joined(separator: "\n")
        
        return Data(content.utf8)
    }
    
    func write(_ data: Data, using fastlaneParametersFolder: Path) throws {
            if fastlaneParametersFolder.isDirectory, fastlaneParametersFolder.exists {
                let fastlaneParametersFile = Path(fastlaneParametersFolder.string+StaticPath
                                                    .Fastlane.variantsParametersFileName)
                
                // Only proceed to write to file if such doesn't yet exist
                // Or does exist and 'isWritable'
                guard !fastlaneParametersFile.exists
                        || fastlaneParametersFile.isWritable else {
                    throw TemplateDoesNotExist(templateNames: [fastlaneParametersFolder.string])
                }
                
                // Write to file
                try fastlaneParametersFile.write(data)
            } else {
                throw TemplateDoesNotExist(templateNames: [fastlaneParametersFolder.string])
            }
    }
    
    private let templatePath: Path
}
