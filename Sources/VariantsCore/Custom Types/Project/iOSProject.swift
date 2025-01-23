//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Balazs Toth
//

// swiftlint:disable type_name

import Foundation
import ArgumentParser
import PathKit

class iOSProject: Project {
    init(
        specHelper: SpecHelper,
        configFactory: XCFactory = XCConfigFactory(),
        parametersFactory: ParametersFactory = FastlaneParametersFactory(),
        yamlParser: YamlParser = YamlParser()
    ) {
        self.configFactory = configFactory
        self.parametersFactory = parametersFactory
        super.init(specHelper: specHelper, yamlParser: yamlParser)
    }

    // MARK: - Public

    override func setup(spec: String, skipFastlane: Bool, verbose: Bool) throws {
        guard let configuration = try loadConfiguration(spec) else {
            throw RuntimeError("Unable to load spec '\(spec)'")
        }

        try createVariants(with: configuration, spec: spec)
        setupFastlane(with: configuration, skip: skipFastlane)
    }

    override func `switch`(to variant: String, spec: String, verbose: Bool) throws {
        guard let configuration = try loadConfiguration(spec) else {
            throw RuntimeError("Unable to load specs '\(spec)' for platform 'ios'")
        }

        guard let desiredVariant = configuration.variants.first(where: { $0.name.lowercased() == variant.lowercased() }) else {
            throw ValidationError("Variant '\(variant)' not found.")
        }

        do {
            try switchTo(desiredVariant, spec: spec, configuration: configuration)
        } catch {
            throw RuntimeError("Unable to switch variants - Check your YAML spec")
        }
        
        if let postSwitchScript = desiredVariant.postSwitchScript {
            try self.runPostSwitchScript(postSwitchScript)
        }
    }
    
    override func list(spec: String) throws -> [Variant] {
        guard let variants = try loadConfiguration(spec)?.variants else {
            throw RuntimeError("Unable to load specs '\(spec)' for platform 'ios'")
        }
        
        return variants
    }

    // MARK: - Private

    private func loadConfiguration(_ path: String) throws -> iOSConfiguration? {
        let configurationPath = Path(path)
        guard !configurationPath.isDirectory else {
            throw ValidationError("Error: \(configurationPath) is a directory path")
        }
        
        do {
            return try yamlParser.extractConfiguration(from: path, platform: .ios, logger: specHelper.logger).ios
        } catch {
            Logger.shared.logError(item: (error as NSError).debugDescription)
            throw RuntimeError("Unable to load your YAML spec")
        }
    }

    private func switchTo(_ variant: iOSVariant, spec: String, configuration: iOSConfiguration) throws {
        specHelper.logger.logInfo(item: "Found: \(variant.title)")

        // Create 'variants.xcconfig' with parameters whose
        // destination are set as '.project'
        do {
            try configFactory.createConfig(
                for: configuration.target,
                variant: variant,
                xcodeProj: configuration.xcodeproj,
                configPath: Path(spec).absolute().parent(),
                addToXcodeProj: false
            )
        } catch {
            Logger.shared.logFatal(item: error.localizedDescription)
        }

        var customProperties: [CustomProperty] = (variant.custom ?? []) + (configuration.custom ?? [])
        customProperties.append(variant.destinationProperty)
        // Create 'variants_params.rb' with parameters whose
        // destination are set as '.fastlane'
        try? storeFastlaneParams(customProperties)

        try parametersFactory.createMatchFile(for: variant, target: configuration.target)
    }
    
    private func runPostSwitchScript(_ script: String) throws {
        guard let outputString = try Bash("bash", arguments: "-c", script).capture() else { return }
        Logger.shared.logInfo(item: outputString)
    }

    private func createVariants(with configuration: iOSConfiguration, spec: String) throws {
        guard let defaultVariant = configuration.variants
                .first(where: { $0.name.lowercased() == "default" }) else {
            throw ValidationError("Variant 'default' not found.")
        }

        // Create 'variants.xcconfig' with parameters whose
        // destination are set as '.project'
        let configPath = Path(spec).absolute().parent()
        do {
            try configFactory.createConfig(
                for: configuration.target,
                variant: defaultVariant,
                xcodeProj: configuration.xcodeproj,
                configPath: configPath,
                addToXcodeProj: true)
        } catch {
            Logger.shared.logFatal(item: error.localizedDescription)
        }
    }

    // swiftlint:disable:next function_body_length
    private func setupFastlane(with configuration: iOSConfiguration, skip: Bool) {
        guard skip == false else {
            return Logger.shared.logInfo("Skipped Fastlane setup for iOS", item: "")
        }

        Logger.shared.logInfo("Setting up Fastlane for iOS", item: "")
        do {
            let path = try TemplateDirectory().path
            try Bash("cp", arguments: "-R", "\(path.absolute())/ios/_fastlane/", ".")
                .run()

            let projectSourceFolder = configuration.target.source.path
            let baseSetupCompletedMessage =
                """
                ✅  Your variants configuration was setup
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

            if StaticPath.Fastlane.baseFolder.isDirectory {

                guard let defaultVariant = configuration.variants
                        .first(where: { $0.name.lowercased() == "default" })
                else {
                    throw ValidationError("Variant 'default' not found.")
                }
                var customProperties: [CustomProperty] = (defaultVariant.custom ?? []) + (configuration.custom ?? [])
                customProperties.append(defaultVariant.destinationProperty)

                // Create 'variants_params.rb' with parameters whose
                // destination are set as '.fastlane'
                try storeFastlaneParams(customProperties)

                try parametersFactory.createMatchFile(for: defaultVariant, target: configuration.target)

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
    
    private func storeFastlaneParams(_ properties: [CustomProperty]) throws {
        let fastlaneProperties = properties.filter { $0.destination == .fastlane }
        guard !fastlaneProperties.isEmpty else { return }
        try parametersFactory.createParametersFile(in: StaticPath.Fastlane.variantsParametersFile,
                                                 renderTemplate: StaticPath.Template.fastlaneParametersFileName,
                                                 with: fastlaneProperties)
    }

    private let configFactory: XCFactory
    private let parametersFactory: ParametersFactory
}

// swiftlint:enable type_name
