//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import Stencil

class SecretsFactory {
    init(logger: Logger = Logger(verbose: false)) {
        self.logger = logger
    }
    
    /// Updates `Variants.swift` with `Variants.Secrets` containing
    /// encrypted static variables
    /// - Parameters:
    ///   - configFilePath: Path to XCConfig file
    ///   - variant: Chosen variant, as seen in `variants.yml`
    func updateSecrets(with configFilePath: Path, variant: iOSVariant) {
        do {
            let path = try TemplateDirectory().path
            guard let variantsGybTemplatePath = try? path.safeJoin(path: Path("ios/"))
            else { return }
            
            if let secrets = variant.custom?.envVars() {
                let context = [
                    "secrets": secrets
                ] as [String: Any]
                
                let environment = Environment(loader: FileSystemLoader(paths: [variantsGybTemplatePath.absolute()]))
                let rendered = try environment.renderTemplate(name: StaticPath.Template.variantsSwiftGybFileName,
                                                              context: context)
                
                // Replace multiple empty lines by one only
                let lines = rendered.split(whereSeparator: \.isNewline)
                let content = lines.joined(separator: "\n")
                
                try write(Data(content.utf8), using: configFilePath.parent().absolute())
                
                let variantsGybFile = try configFilePath.parent().absolute()
                    .safeJoin(path: Path(StaticPath.Xcode.variantsGybFileName))
                try variantsGybFile.delete()
            }
        } catch {
            let variantsFile = try? configFilePath.parent().absolute()
                .safeJoin(path: Path(StaticPath.Xcode.variantsFileName))
            logger.logWarning(item: """
                Something went wrong while generating 'Variants.Secrets' in '\(variantsFile ?? "Variants.swift")'
                """)
            dump(error)
        }
    }
    
    private func write(_ data: Data, using folder: Path = Path("/tmp/")) throws {
        if folder.isDirectory, folder.exists {
            let variantsGybFile = try folder.safeJoin(path: Path(StaticPath.Xcode.variantsGybFileName))
            
            // Only proceed to write to file if such doesn't yet exist
            // Or does exist and 'isWritable'
            guard !variantsGybFile.exists
                    || variantsGybFile.isWritable else {
                throw TemplateDoesNotExist(templateNames: [folder.string])
            }
            
            // Write to file
            try variantsGybFile.write(data)
            
            if
                try UtilsDirectory().path.exists,
                let gybExecutablePath = try? UtilsDirectory().path.safeJoin(path: "gyb"),
                let fileContent = try? variantsGybFile.read(),
                fileContent == data {
                
                try Bash(gybExecutablePath.absolute().description,
                         arguments:
                            "--line-directive",
                            "",
                            "-o",
                            "Variants.swift",
                            variantsGybFile.absolute().description
                ).run()
                
                logger.logInfo("⚙️  ", item: """
                    '\(variantsGybFile.parent().abbreviate().string)/Variants.swift' has been generated with success
                    """, color: .green)
            }
        } else {
            throw TemplateDoesNotExist(templateNames: [folder.string])
        }
    }
    
    let logger: Logger
}

fileprivate extension Sequence where Iterator.Element == CustomProperty {
    func envVars() -> [CustomProperty] {
        return self
            .filter({ $0.destination == .project && $0.processForEnvironment().isEnvVar })
            .map { (property) -> CustomProperty in
                let processed = property.processForEnvironment()
                if processed.isEnvVar {
                    return CustomProperty(name: property.name,
                                          value: "os.environ.get('"+processed.string+"')",
                                          destination: property.destination)
                }
                return property
            }
    }
    
    func literal() -> [CustomProperty] {
        return self
            .filter({ $0.destination == .project && !$0.processForEnvironment().isEnvVar })
    }
}
