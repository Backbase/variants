//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
@testable import VariantsCore

class MockFastlaneFactory: FastlaneFactory {
    var createParametersCache: [(folder: Path, parameters: [CustomProperty])] = []
    var renderCache: [[CustomProperty]] = []
    var writeCache: [(data: Data, fastlaneParametersFolder: Path)] = []
    
    func createParametersFile(in folder: Path, with parameters: [CustomProperty]) throws {
        createParametersCache.append((folder: folder, parameters: parameters))
    }
    
    func render(parameters: [CustomProperty]) throws -> Data? {
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
