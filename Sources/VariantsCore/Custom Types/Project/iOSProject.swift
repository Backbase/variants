//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Balazs Toth
//

import Foundation
import ArgumentParser
import PathKit

// swiftlint:disable type_name

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
            throw RuntimeError("Unable to load your YAML spec")
        }
    }

    private func switchTo(_ variant: iOSVariant, spec: String, configuration: iOSConfiguration) throws {
        Logger.shared.logInfo(item: "Found: \(variant.configIdSuffix)")

        configuration.targets
            .map { (key: $0.key, value: $0.value)}
            .forEach { result in
                
                // Create 'variants.xcconfig' with parameters whose
                // destination are set as '.project'
                configFactory.createConfig(
                    with: result,
                    variant: variant,
                    xcodeProj: configuration.xcodeproj,
                    configPath: Path(spec).absolute().parent(),
                    addToXcodeProj: false
                )
                
                var customProperties: [CustomProperty] = (variant.custom ?? []) + (configuration.custom ?? [])
                customProperties.append(variant.destinationProperty)
                
                // Create 'variants_params.rb' with parameters whose
                // destination are set as '.fastlane'
                try? storeFastlaneParams(customProperties)
                
                try? parametersFactory.createParametersFile(in: StaticPath.Fastlane.parametersFolder,
                                                         renderTemplate: StaticPath.Template.matchParametersFileName,
                                                         with: variant.signing?.customProperties() ?? [])
            }
    }

    private func createVariants(with configuration: iOSConfiguration, spec: String) throws {
        try configuration.targets
            .map { (key: $0.key, value: $0.value) }
            .forEach { target in
                
                guard let defaultVariant = configuration.variants
                        .first(where: { $0.name.lowercased() == "default" }) else {
                    throw ValidationError("Variant 'default' not found.")
                }
                
                // Create 'variants.xcconfig' with parameters whose
                // destination are set as '.project'
                let configPath = Path(spec).absolute().parent()
                configFactory.createConfig(with: target,
                                           variant: defaultVariant,
                                           xcodeProj: configuration.xcodeproj,
                                           configPath: configPath,
                                           addToXcodeProj: true)
            }
    }

    // swiftlint:disable function_body_length
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
                            .first(where: { $0.name.lowercased() == "default" }) else {
                        throw ValidationError("Variant 'default' not found.")
                    }
                    var customProperties: [CustomProperty] = (defaultVariant.custom ?? []) + (configuration.custom ?? [])
                    customProperties.append(defaultVariant.destinationProperty)
                    
                    // Create 'variants_params.rb' with parameters whose
                    // destination are set as '.fastlane'
                    try storeFastlaneParams(customProperties)
                    
                    try parametersFactory.createParametersFile(in: StaticPath.Fastlane.parametersFolder,
                                                             renderTemplate: StaticPath.Template.matchParametersFileName,
                                                             with: defaultVariant.signing?.customProperties() ?? [])
                    
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
    // swiftlint:enable function_body_length
    
    private func storeFastlaneParams(_ properties: [CustomProperty]) throws {
        let fastlaneProperties = properties.filter { $0.destination == .fastlane }
        guard !fastlaneProperties.isEmpty else { return }
        try parametersFactory.createParametersFile(in: StaticPath.Fastlane.parametersFolder,
                                                 renderTemplate: StaticPath.Template.fastlaneParametersFileName,
                                                 with: fastlaneProperties)
    }

    private let configFactory: XCFactory
    private let parametersFactory: ParametersFactory
}
