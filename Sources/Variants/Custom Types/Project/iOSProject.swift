//
// Created by Balazs Toth on 25/10/2020.
// Copyright © 2020. All rights reserved.
// 

import Foundation
import ArgumentParser
import PathKit

class iOSProject: Project {
    init(
        specFactory: VariantSpecFactory = VariantSpecFactory(),
        configFactory: XCConfigFactory = XCConfigFactory()
    ) {
        self.specFactory = specFactory
        self.configFactory = configFactory
    }

    // MARK: - Public

    func initialize(verbose: Bool) throws {
        do {
            let path = try TemplateDirectory().path
            try specFactory.generateSpec(path: path, platform: .ios)
        } catch {
            throw error
        }
    }

    func setup(spec: String, skipFastlane: Bool, verbose: Bool) throws {
        let configurationHelper = ConfigurationHelper(verbose: verbose)

        guard let configuration = try configurationHelper.loadConfiguration(spec, platform: .ios) else {
            throw RuntimeError("Unable to load spec '\(spec)'")
        }
        
        createVariants(with: configuration, spec: spec)
        setupFastlane(skipFastlane)
    }

    func `switch`(to variant: String, spec: String, verbose: Bool) throws {
        let configurationHelper = ConfigurationHelper(verbose: verbose)

        guard let configuration = try configurationHelper.loadConfiguration(spec, platform: .ios) else {
            throw RuntimeError("Unable to load specs '\(spec)'")
        }

        guard let desiredVariant = configuration.ios?.variants.first(where: { $0.name == variant }) else {
            throw ValidationError("Variant \(variant) not found.")
        }

        do {
            try switchTo(desiredVariant, spec: spec, configuration: configuration)
        } catch {
            throw RuntimeError("Unable to switch variants - Check your YAML spec")
        }
    }

    // MARK: - Private

    private func switchTo(_ variant: Variant, spec: String, configuration: Configuration) throws {
        Logger.shared.logInfo(item: "Found: \(variant.configIdSuffix)")

        configuration.ios?.targets
            .map { (key: $0.key, value: $0.value)}
            .forEach { result in
                configFactory.createConfig(
                    with: result,
                    variant: variant,
                    xcodeProj: configuration.ios?.xcodeproj,
                    configPath: Path(spec).absolute().parent(),
                    addToXcodeProj: false
                )
            }
    }

    private func createVariants(with configuration: Configuration, spec: String) {
        configuration.ios?.targets
            .map { (key: $0.key, value: $0.value) }
            .forEach { result in
                try? createConfig(
                    with: result,
                    spec: spec,
                    variants: configuration.ios?.variants,
                    xcodeProj: configuration.ios?.xcodeproj
                )
            }
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

    private func createConfig(with target: NamedTarget, spec: String, variants: [Variant]?, xcodeProj: String?) throws {
        guard
            let variants = variants,
            !variants.isEmpty,
            let defaultVariant = variants.first(where: { $0.name == "default" })
        else {
            throw ValidationError("Missing mandatory variant: 'default'")
        }

        let configPath = Path(spec).absolute().parent()
        configFactory.createConfig(with: target, variant: defaultVariant, xcodeProj: xcodeProj, configPath: configPath)
    }

    private let specFactory: VariantSpecFactory
    private let configFactory: XCConfigFactory
}
