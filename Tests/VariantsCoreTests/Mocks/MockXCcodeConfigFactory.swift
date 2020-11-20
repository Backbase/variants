//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation
import PathKit
@testable import VariantsCore
// swiftlint:disable colon

class MockXCcodeConfigFactory: XCFactory {
    var writeContentCache: [(content: String, file: Path, force: Bool)] = []
    var writeJSONCache: [(encodableObject: Encodable, file: Path)] = []
    var createConfigCache: [(target: NamedTarget,
                             variant: iOSVariant,
                             xcodeProj: String?,
                             configPath: Path,
                             addToXcodeProj: Bool?)] = []
    
    init(logLevel: Bool = false) {
        logger = Logger(verbose: logLevel)
    }
    
    func write(_ stringContent: String, toFile file: Path, force: Bool) -> (Bool, Path?) {
        writeContentCache.append((content: stringContent, file: file, force: force))
        return (true, file)
    }
    
    func writeJSON<T>(_ encodableObject: T, toFile file: Path) -> (Bool, Path?) where T : Encodable {
        writeJSONCache.append((encodableObject: encodableObject, file: file))
        return (true, file)
    }
    
    func createConfig(with target: NamedTarget,
                      variant: iOSVariant,
                      xcodeProj: String?,
                      configPath: Path,
                      addToXcodeProj: Bool?) {
        createConfigCache.append((target: target,
                                  variant: variant,
                                  xcodeProj: xcodeProj,
                                  configPath: configPath,
                                  addToXcodeProj: addToXcodeProj))
    }
    
    var xcconfigFileName: String = "variants.xcconfig"
    var logger: Logger
}
