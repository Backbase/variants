//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Balazs Toth
//

import Foundation
import ArgumentParser
import PathKit

class iOSProject: Project {
    init(
        specHelper: SpecHelper,
        configFactory: XCConfigFactory = XCConfigFactory(),
        yamlParser: YamlParser = YamlParser()
    ) {
        self.configFactory = configFactory
        super.init(specHelper: specHelper, yamlParser: yamlParser)
    }

    // MARK: - Public

    override func setup(spec: String, skipFastlane: Bool, verbose: Bool) throws {
        guard let configuration = try loadConfiguration(spec) else {
            throw RuntimeError("Unable to load spec '\(spec)'")
        }

        createVariants(with: configuration, spec: spec)
        setupFastlane(with: configuration, skip: skipFastlane)
    }

    override func `switch`(to variant: String, spec: String, verbose: Bool) throws {
        guard let configuration = try loadConfiguration(spec) else {
            throw RuntimeError("Unable to load specs '\(spec)' for platform 'ios'")
        }

        guard let desiredVariant = configuration.variants.first(where: { $0.name.lowercased() == variant.lowercased() }) else {
            throw ValidationError("Variant \(variant) not found.")
        }

        do {
            try switchTo(desiredVariant, spec: spec, configuration: configuration)
        } catch {
            throw RuntimeError("Unable to switch variants - Check your YAML spec")
        }
    }

    // MARK: - Private

    private func loadConfiguration(_ path: String?) throws -> iOSConfiguration? {
        guard let path = path else {
            throw ValidationError("Error: Use '-s' to specify the configuration file")
        }

        let configurationPath = Path(path)
        guard !configurationPath.isDirectory else {
            throw ValidationError("Error: \(configurationPath) is a directory path")
        }
        
        do {
            return try yamlParser.extractConfiguration(from: path, platform: .ios).ios
        } catch {
            Logger.shared.logError(item: (error as NSError).debugDescription)
            Logger.shared.logFatal("❌ ", item: "Unable to load your YAML spec")
            exit(1) // Reduntant exit, otherwise we must return something
        }
    }

    private func switchTo(_ variant: iOSVariant, spec: String, configuration: iOSConfiguration) throws {
        Logger.shared.logInfo(item: "Found: \(variant.configIdSuffix)")

        configuration.targets
            .map { (key: $0.key, value: $0.value)}
            .forEach { result in
                configFactory.createConfig(
                    with: result,
                    variant: variant,
                    xcodeProj: configuration.xcodeproj,
                    configPath: Path(spec).absolute().parent(),
                    addToXcodeProj: false
                )
            }
    }

    private func createVariants(with configuration: iOSConfiguration, spec: String) {
        configuration.targets
            .map { (key: $0.key, value: $0.value) }
            .forEach { result in
                try? createConfig(
                    with: result,
                    spec: spec,
                    variants: configuration.variants,
                    xcodeProj: configuration.xcodeproj
                )
            }
    }

    private func setupFastlane(with configuration: iOSConfiguration, skip: Bool) {
        if skip {
            Logger.shared.logInfo("Skipped Fastlane setup", item: "")
        } else {
            Logger.shared.logInfo("Setting up Fastlane", item: "")

            do {
                let path = try TemplateDirectory().path
                try Bash("cp", arguments: "-R", "\(path.absolute())/ios/_fastlane/", ".")
                    .run()
                
                let projectSourceFolder = configuration.targets.first?.value.source.path ?? "{{ SOURCE_PATH }}"
                let baseSetupCompletedMessage =
                    """
                    ✅  You variants configuration was setup
                    ✅  For configuration properties with 'environment' destination, a temporary
                        file has been created. You can source this file directly.
                    ✅  '\(projectSourceFolder)/Variants/' has been created.
                        Add that folder to your Xcode project if it wasn't done automatically.
                    ✅  For configuration properties with 'project' destination, they have been
                        stored in '\(projectSourceFolder)/Variants/variants.xcconfig'.
                        These values have been made available to your project via your Info.plist.
                        Use them in your code as 'Variants.configuration["SAMPLE_PROPERTY"]'.
                    🔄  Use 'variants switch --variants <value>' to switch between variants and
                        update the properties in the files described above.

                    That is all.
                    """
                
                var setupCompleteMessage =
                    """

                    We got almost everything done!

                    ❌  Fastlane could not be setup. The template wasn't found or something else went wrong when
                        copying it.

                    """
                
                if Path("./fastlane/").isDirectory {
                    setupCompleteMessage =
                        """

                        Your setup is complete, congratulations! 🎉
                        However, you still need to provide some parameters in order for fastlane to run correctly.

                        ⚠️  Check the files in 'fastlane/parameters/', change the parameters accordingly,
                            provide environment variables when applicable.
                        ⚠️  If you use Cocoapods-art, enable it in 'fastlane/Cocoapods'
                        ⚠️  Change your signing configuration in 'fastlane/Match' and potentially 'fastlane/Deploy'

                        """
                    
                    Logger.shared.logInfo("🚀 ", item: "Fastlane setup with success", color: .green)
                    Logger.shared.logInfo("👇  Next steps ", item: "", color: .yellow)
                } else {
                    Logger.shared.logWarning("", item: "Fastlane setup couldn't be completed")
                    Logger.shared.logInfo("👇  What happened ", item: "", color: .yellow)
                }
                
                setupCompleteMessage += baseSetupCompletedMessage
                setupCompleteMessage.enumerateLines { (line, _) in
                    Logger.shared.logInfo("", item: line, color: .yellow)
                }

            } catch {
                Logger.shared.logFatal(item: error.localizedDescription)
            }
        }
    }

    private func createConfig(with target: NamedTarget, spec: String, variants: [iOSVariant]?, xcodeProj: String?) throws {
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

    private let configFactory: XCConfigFactory
}
