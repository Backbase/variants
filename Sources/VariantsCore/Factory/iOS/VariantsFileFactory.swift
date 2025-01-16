//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
import Stencil

class VariantsFileFactory {
    init(logger: Logger = Logger(verbose: false)) {
        self.logger = logger
    }
    
    /// Updates `Variants.swift` with `Variants.Secrets` containing encrypted static variables
    /// and `Variants.ConfigurationValueKey` as keys for custom configuration values
    /// - Parameters:
    ///   - configFilePath: Path to XCConfig file
    ///   - variant: Chosen variant, as seen in `variants.yml`
    func updateVariantsFile(with configFilePath: Path, variant: iOSVariant) {
        do {
            let path = try TemplateDirectory().path
            guard let variantsGybTemplatePath = try? path.safeJoin(path: Path("ios/"))
            else { return }
            let secrets = variant.custom?.secrets() ?? []
            let configurationValues = variant.custom?.configurationValues() ?? []
            logger.logInfo(item: "Writing custom properties: \(configurationValues)")
            let context = [
                "secrets": secrets,
                "configurationValues": configurationValues
            ] as [String: Any]
            let environment = Environment(loader: FileSystemLoader(paths: [variantsGybTemplatePath.absolute()]))
            let rendered = try environment.renderTemplate(name: StaticPath.Template.variantsSwiftGybFileName,
                                                          context: context)
            // Replace multiple empty lines by one only
            let lines = rendered.split(whereSeparator: \.isNewline)
            let content = lines.joined(separator: "\n")
            
            try write(Data(content.utf8), using: configFilePath.parent().absolute())
            logger.logInfo(item: "Successfully write file at \(configFilePath.parent().absolute().string)")
            let variantsGybFile = try configFilePath.parent().absolute()
                .safeJoin(path: Path(StaticPath.Xcode.variantsGybFileName))
            try variantsGybFile.delete()
            logger.logInfo(item: "Successfully removed gyb at \(variantsGybFile.string)")
        } catch {
            logger.logWarning(item: "Failed to write to variants file")
            let variantsFile = try? configFilePath.parent().absolute()
                .safeJoin(path: Path(StaticPath.Xcode.variantsFileName))
            logger.logWarning(item: """
                Something went wrong while generating '\(variantsFile ?? "Variants.swift")'
                """)
            dump(error)
        }
    }
    
    private func write(_ data: Data, using folder: Path = Path("/tmp/")) throws {
        guard folder.isDirectory, folder.exists else {
            throw TemplateDoesNotExist(templateNames: [folder.string])
        }

        let variantsGybFile = try folder.safeJoin(path: Path(StaticPath.Xcode.variantsGybFileName))
        // Only proceed to write to file if such doesn't yet exist
        // Or does exist and 'isWritable'
        guard !variantsGybFile.exists || variantsGybFile.isWritable else {
            throw TemplateDoesNotExist(templateNames: [folder.string])
        }

        try variantsGybFile.write(data)
        guard
            try UtilsDirectory().path.exists,
            let gybExecutablePath = try? UtilsDirectory().path.safeJoin(path: "gyb"),
            let fileContent = try? variantsGybFile.read(),
            fileContent == data
        else { return }

        let gybStdErr = try Bash(gybExecutablePath.absolute().description,
                 arguments:
                    "--line-directive",
                    "",
                    "-o",
                    "Variants.swift",
                    variantsGybFile.absolute().description
        ).capture(stream: .stderr)
        let variantsFilePath = "\(variantsGybFile.parent().abbreviate().string)/Variants.swift"
        handleGybErrors(message: gybStdErr, variantsFilePath: variantsFilePath)
        logger.logInfo("⚙️  ", item: "'\(variantsFilePath)' has been generated with success", color: .green)
    }
    
    private func handleGybErrors(message: String?, variantsFilePath: String) {
        guard let message, !message.isEmpty else { return }

        switch message {
        case _ where message.contains("env: python2.7: No such file or directory"):
            logger.logFatal(item:
            """
            We're unable to find a 'python2.7' executable.
            Install 'python2.7' or ensure it's in your executables path and try running this Variants command again.
            Tip:
                * Install pyenv (brew install pyenv)
                * Install python2.7 (pyenv install python2.7)
                * Add "$(pyenv root)/shims" to your PATH
            """)
        case _ where message.contains("for chunk in chunks(encode(os.environ.get("):
            logger.logFatal(item:
            """
            We're unable to create 'Variants.Secrets' in '\(variantsFilePath)'.
            Ensure that custom config values whose `env: true` are actually environment variables.
            """)
        case _ where message.contains("pyenv: python2.7: command not found"):
            logger.logFatal(item:
            """
            Looks like you have pyenv installed but the current configured version is not correct.
            Please, select the latest build of python 2.7 as local version.
            For example: `pyenv local 2.7`
            """)
        default:
            logger.logFatal(item: message as Any)
        }
    }
    
    let logger: Logger
}

fileprivate extension Sequence where Iterator.Element == CustomProperty {
    func secrets() -> [CustomProperty] {
        return self
            .filter({ $0.destination == .project && $0.isEnvironmentVariable })
            .map { (property) -> CustomProperty in
                return CustomProperty(name: property.name,
                                      value: "os.environ.get('"+property.environmentValue+"')",
                                      destination: property.destination)
            }
    }
    
    func configurationValues() -> [CustomProperty] {
        return self
            .filter({ $0.destination == .project && !$0.isEnvironmentVariable })
    }
}
