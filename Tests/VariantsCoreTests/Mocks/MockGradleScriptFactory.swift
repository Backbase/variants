//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
@testable import VariantsCore

class MockGradleScriptFactory: GradleFactory {
    var writeContentCache: [(data: Data, gradleScriptFolder: Path)] = []
    var renderContentCache: [(configuration: AndroidConfiguration,
                            variant: AndroidVariant)] = []
    var createScriptCache: [(configuration: AndroidConfiguration,
                             variant: AndroidVariant)] = []
    
    init(templatePath: Path? = try? TemplateDirectory().path) {
        self.templatePath = templatePath
    }
    
    func createScript(with configuration: AndroidConfiguration, variant: AndroidVariant) {
        createScriptCache.append((configuration: configuration, variant: variant))
    }
    
    func render(with configuration: AndroidConfiguration, variant: AndroidVariant) throws -> Data? {
        renderContentCache.append((configuration: configuration, variant: variant))
        return nil
    }
    
    func write(_ data: Data, using gradleScriptFolder: Path) throws {
        writeContentCache.append((data: data, gradleScriptFolder: gradleScriptFolder))
    }
    
    private let templatePath: Path?
}
