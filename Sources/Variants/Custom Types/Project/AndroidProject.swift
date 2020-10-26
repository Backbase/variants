//
// Created by Balazs Toth on 25/10/2020.
// Copyright © 2020. All rights reserved.
// 

import Foundation
import PathKit
import ArgumentParser

class AndroidProject: Project {
    init(
        specFactory: VariantSpecFactory = VariantSpecFactory(),
        yamlParser: YamlParser = YamlParser()
    ) {
        self.specFactory = specFactory
        self.yamlParser = yamlParser
    }

    // MARK: - Public

    func initialize(verbose: Bool) throws {
        do {
            let path = try TemplateDirectory().path
            try specFactory.generateSpec(path: path, platform: .android)
        } catch {
            throw error
        }
    }

    func setup(spec: String, skipFastlane: Bool, verbose: Bool) throws {
        guard let configuration = try loadConfiguration(spec) else {
            throw RuntimeError("Unable to load spec '\(spec)'")
        }

        createVariants(with: configuration, spec: spec)
        setupFastlane(skipFastlane)
    }

    func `switch`(to variant: String, spec: String, verbose: Bool) throws {
        guard let configuration = try loadConfiguration(spec) else {
            throw RuntimeError("Unable to load specs '\(spec)'")
        }

        guard let desiredVariant = configuration.android?.variants.first(where: { $0.name == variant }) else {
            throw ValidationError("Variant \(variant) not found.")
        }

        do {
            try switchTo(desiredVariant, spec: spec, configuration: configuration)
        } catch {
            throw RuntimeError("Unable to switch variants - Check your YAML spec")
        }
    }

    // MARK: - Private

    private func loadConfiguration(_ path: String?) throws -> Configuration? {
        guard let path = path else {
            throw ValidationError("Error: Use '-s' to specify the configuration file")
        }

        let configurationPath = Path(path)
        guard !configurationPath.isDirectory else {
            throw ValidationError("Error: \(configurationPath) is a directory path")
        }

        return yamlParser.extractConfiguration(from: path, platform: .android)
    }

    private func process(variant: String, spec: String, configuration: Configuration) throws {

    }

    private func switchTo(_ variant: Variant, spec: String, configuration: Configuration) throws {
        Logger.shared.logInfo(item: "Found: \(variant.configIdSuffix)")
    }

    private func createVariants(with configuration: Configuration, spec: String) {

    }

    private func setupFastlane(_ skip: Bool) {
        if skip {
            Logger.shared.logInfo("Skipped Fastlane setup", item: "")
        } else {
            Logger.shared.logInfo("Setting up Fastlane", item: "")

            do {
                let path = try TemplateDirectory().path
                try Bash("cp", arguments: "-R", "\(path.absolute())/ios/_fastlane/*", ".")
                    .run()
                Logger.shared.logInfo("🚀 ", item: "Fastlane setup with success", color: .green)

                let setupCompleteMessage =
                    """

                    Your setup is complete, congratulations! 🎉

                    However, you still need to provide some parameters in order for fastlane to run correctly.

                    ⚠️  Check the files in 'fastlane/parameters/', change the parameters accordingly,
                        provide environment variables when applicable.
                    ⚠️  If you use Cocoapods-art, enable it in 'fastlane/Cocoapods'
                    ⚠️  Change your signing configuration in 'fastlane/Match' and potentially 'fastlane/Deploy'

                    That is all.
                    """

                Logger.shared.logInfo("👇  Next steps ", item: "", color: .yellow)
                setupCompleteMessage.enumerateLines { (line, _) in
                    Logger.shared.logInfo("", item: line, color: .yellow)
                }

            } catch {
                Logger.shared.logFatal(item: error.localizedDescription)
            }
        }
    }

    private let specFactory: VariantSpecFactory
    private let yamlParser: YamlParser
}
