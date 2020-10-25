//
// Copyright © 2020. All rights reserved.
// 

import Foundation
import PathKit

struct PlatformDetector {
    enum Errors: Error, LocalizedError {
        case couldNotDetectPlatform
        case multiplePlatformsAvailable

        var errorDescription: String? {
            switch self {
            case .couldNotDetectPlatform:
                return NSLocalizedString(
                    "❌ Could not find an Android or Xcode project in your working directory.",
                    comment: ""
                )
            case .multiplePlatformsAvailable:
                return NSLocalizedString(
                    """
                    ❌ Found an Android and Xcode project in your working directory.
                    Please specify the platform you want using `--platform <value>`
                    """,
                    comment: ""
                )
            }
        }
    }

    /// Tries to automatically detect the platform based on the given argument.
    /// If the argument can't be parsed to a platform, the function will try to determinte the project based on
    /// the presence of certain project files.
    /// If multiple platforms are available, it will throw an error instead.
    /// - Parameter argument: The command line argument to use as the basis of platform detection.
    /// - Throws: `PlatformDetector.Errors`
    /// - Returns: The parsed or detected Platform
    static func detect(fromArgument argument: String) throws -> Platform {
        guard let platform = Platform(argument: argument) else {
            switch availablePlatforms.count {
            case 0:
                throw Errors.couldNotDetectPlatform
            case 1:
                return availablePlatforms.first!
            default:
                throw Errors.multiplePlatformsAvailable
            }
        }

        return platform
    }

    // MARK: - Private

    private static var xcodeProjects: [Path] {
        Path.glob("*.xcodeproj")
    }

    private static var gradleProjects: [Path] {
        Path.glob("build.gradle")
    }

    private static var availablePlatforms: [Platform] {
        [
            xcodeProjects.isEmpty ? nil : .ios,
            gradleProjects.isEmpty ? nil : .android
        ]
        .compactMap { $0 }
    }
}
