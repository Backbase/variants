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
    var createParametersCache: [(folder: Path, renderTemplate: String, parameters: [CustomProperty])] = []
    var renderCache: [[CustomProperty]] = []
    var writeCache: [(data: Data, fastlaneParametersFolder: Path)] = []
    
    func createParametersFile(in folder: Path, renderTemplate: String, with parameters: [CustomProperty]) throws {
        createParametersCache.append((folder: folder, renderTemplate: renderTemplate, parameters: parameters))
    }
    
    func render(parameters: [CustomProperty], renderTemplate: String) throws -> Data? {
        renderCache.append(parameters)
        return nil
    }
    
    func write(_ data: Data, using fastlaneParametersFolder: Path) throws {
        writeCache.append((data: data, fastlaneParametersFolder: fastlaneParametersFolder))
    }
}

class SpecHelperMock: SpecHelper {
    var generateCache: [Path] = []
    
    override func generate(from path: Path) throws {
        generateCache.append(path)
    }
}
