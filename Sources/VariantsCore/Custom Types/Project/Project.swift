//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Balazs Toth
//

import Foundation

class Project {
    init(
        specHelper: SpecHelper,
        yamlParser: YamlParser = YamlParser()
    ) {
        self.specHelper = specHelper
        self.yamlParser = yamlParser
    }

    // MARK: - Commands

    func initialize(verbose: Bool) throws {
        let path = try TemplateDirectory().path
        try specHelper.generate(from: path)
    }

    func setup(spec: String, skipFastlane: Bool, verbose: Bool) throws {
        // No-op
    }

    func `switch`(to variant: String, spec: String, verbose: Bool) throws {
        // No-op
    }

    // MARK: - Helper functions

    internal let specHelper: SpecHelper
    internal let yamlParser: YamlParser
}
