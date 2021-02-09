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
    var createMatchFileCache: [(variant: iOSVariant, target: iOSTarget)] = []
    var renderCache: [[String: Any]] = []
    var writeCache: [(data: Data, parametersFile: Path)] = []
    
    func createParametersFile(in file: Path, renderTemplate: String, with parameters: [CustomProperty]) throws {
        createParametersCache.append((file: file, renderTemplate: renderTemplate, parameters: parameters))
    }
    
    func createMatchFile(using variant: iOSVariant, target: iOSTarget) throws {
        createMatchFileCache.append((variant: variant, target: target))
    }
    
    func render(context: [String: Any], renderTemplate: String) throws -> Data? {
        renderCache.append(context)
        return nil
    }
    
    func write(_ data: Data, using parametersFile: Path) throws {
        writeCache.append((data: data, parametersFile: parametersFile))
    }
}

class SpecHelperMock: SpecHelper {
    var generateCache: [Path] = []
    
    override func generate(from path: Path, userInputEnabled: Bool = false) throws {
        generateCache.append(path)
    }
}
