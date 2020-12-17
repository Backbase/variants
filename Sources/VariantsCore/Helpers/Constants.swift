//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation
import PathKit

struct Constants {
    static let packageNameKey = "PACKAGE_NAME"
}

struct StaticPath {
    struct Fastlane {
        static let baseFolder = Path("fastlane/")
        static let parametersFolder = Path("fastlane/parameters/")
        static let variantsParametersFile = Path("fastlane/parameters/variants_params.rb")
        static let matchParametersFile = Path("fastlane/parameters/match_params.rb")
        static let matchFile = Path("fastlane/Matchfile")
    }
    
    struct Gradle {
        static let variantsScriptFileName = "variants.gradle"
    }
    
    struct Template {
        static let variantsScriptFileName = "variants-template.gradle"
        static let fastlaneParametersFileName = "variants_params_template.rb"
        static let matchParametersFileName = "ios/match_params_template.rb"
        static let matchFileName = "ios/matchfile_template.rb"
    }
}
