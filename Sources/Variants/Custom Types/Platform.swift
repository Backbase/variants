//
// Copyright © 2020 Backbase R&D B.V. All rights reserved.
//

import Foundation
import ArgumentParser
import PathKit

enum Platform: String, ExpressibleByArgument, Codable {
    case ios
    case android
    case unknown
    
    static func detectPlatform() throws -> Platform {
        var availablePlatforms: [Platform] = []
        if let _ = XcodeProjFactory().projectPath() {
            availablePlatforms.append(.ios)
        }
        
        if let _ = Path.glob("build.gradle")
            .first(where: \.exists) {
            availablePlatforms.append(.android)
        }
        
        if availablePlatforms.count > 1 {
            throw PlatformScanError.multiplePlatformsAvailable
        } else if let platform = availablePlatforms.first {
            return platform
        }
        throw PlatformScanError.couldNotDetectPlatform
    }
}

enum PlatformScanError: Error, CustomStringConvertible {
    case couldNotDetectPlatform
    case multiplePlatformsAvailable
    
    var description: String {
        switch self {
        case .couldNotDetectPlatform:
            return "❌ Could not find an Android or Xcode project in your working directory."
        case .multiplePlatformsAvailable:
            return "❌ Found an Android and Xcode project in your working directory. Please specify the platform you want using `--platform <value>`"
        }
    }
}
