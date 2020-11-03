//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation
import PathKit

struct Constants {}

struct StaticPath {
    struct Fastlane {
        static let baseFolder = Path("fastlane/")
        static let parametersFolder = Path("fastlane/parameters/")
        static let variantsParametersFileName = "variants_params.rb"
    }
}
