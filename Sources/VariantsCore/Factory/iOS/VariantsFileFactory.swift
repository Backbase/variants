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

            let context = [
                "secrets": variant.custom?.projectSecretConfigurationValues ?? [],
                "configurationValues": variant.custom?.projectConfigurationValues ?? []
            ] as [String: Any]
            let environment = Environment(loader: FileSystemLoader(paths: [variantsGybTemplatePath.absolute()]))
            let content = try environment.renderTemplate(name: StaticPath.Template.variantsSwiftGybFileName,
                                                          context: context)

            try write(Data(content.utf8), using: configFilePath.parent().absolute())
            let variantsGybFile = try configFilePath.parent().absolute()
                .safeJoin(path: Path(StaticPath.Xcode.variantsGybFileName))
            try variantsGybFile.delete()
        } catch {
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

        let variantsOutputFilePath = "\(variantsGybFile.parent().absolute().string)/Variants.swift"
        let gybStdErr = try Bash(gybExecutablePath.absolute().description,
                 arguments:
                    "--line-directive",
                    "",
                    "-o",
                    variantsOutputFilePath,
                    variantsGybFile.absolute().description
        ).capture(stream: .stderr)
        handleGybErrors(message: gybStdErr, variantsFilePath: variantsOutputFilePath)
        logger.logInfo("⚙️  ", item: "'\(variantsOutputFilePath)' has been generated with success", color: .green)
    }
    
    private func handleGybErrors(message: String?, variantsFilePath: String) {
        guard let message, !message.isEmpty else { return }

        switch message {
        case _ where message.contains("env: python3: No such file or directory"):
            logger.logFatal(item:
            """
            We're unable to find a 'python3' executable.
            Install 'python3' or ensure it's in your executables path and try running this Variants command again.
            Tip:
                * Install pyenv (brew install pyenv)
                * Install python3 (pyenv install python3)
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
            Please, select the latest build of python 3 as local version.
            For example: `pyenv local 3`
            """)
        default:
            logger.logFatal(item: message as Any)
        }
    }
    
    let logger: Logger
}
