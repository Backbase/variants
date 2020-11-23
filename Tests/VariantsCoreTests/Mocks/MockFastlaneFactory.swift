//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
@testable import VariantsCore

class MockFastlaneFactory: ParametersFactory {
    var createParametersCache: [(file: Path, renderTemplate: String, parameters: [CustomProperty])] = []
    var renderCache: [[CustomProperty]] = []
    var writeCache: [(data: Data, parametersFile: Path)] = []
    
    func createParametersFile(in file: Path, renderTemplate: String, with parameters: [CustomProperty]) throws {
        createParametersCache.append((file: file, renderTemplate: renderTemplate, parameters: parameters))
    }
    
    func render(parameters: [CustomProperty], renderTemplate: String) throws -> Data? {
        renderCache.append(parameters)
        return nil
    }
    
    func write(_ data: Data, using parametersFile: Path) throws {
        writeCache.append((data: data, parametersFile: parametersFile))
    }
}

class SpecHelperMock: SpecHelper {
    var generateCache: [Path] = []
    
    override func generate(from path: Path) throws {
        generateCache.append(path)
    }
}
