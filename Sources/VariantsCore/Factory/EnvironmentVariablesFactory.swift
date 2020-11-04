//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

class EnvironmentVariablesFactory {
    
    init(consolePrinter: StdoutPrinter = StdoutPrinter()) {
        self.consolePrinter = consolePrinter
    }
    
    /// Store  properties whose destination is '.envVar' as environment variables
    /// on temporary file.
    /// - Parameters:
    ///   - properties: Optional array of CustomProperty
    func storeEnvironmentProperties(_ properties: [CustomProperty]?) {
        let environmentProperties = properties?.filter { $0.destination == .envVar } ?? []
        guard !environmentProperties.isEmpty else { return }
        var mutableContent = ""
        environmentProperties.forEach { property in
            mutableContent.appendAsExportVariable(property.name, value: property.value)
        }
        
        if let path = mutableContent.writeToTemporaryFile() {
            consolePrinter.print(item: "EXPORT_ENVIRONMENTAL_VARIABLES_PATH=\(path)")
        } else {
            Logger.shared.logError(item: """
            Could not generate the temporary file for the environment variables.
            """)
        }
    }
    
    private let consolePrinter: StdoutPrinter
}

fileprivate extension String {
    func writeToTemporaryFile() -> String? {
        do {
            return try FileManager.default.writeTemporaryFile(withContent: self)
        } catch {
            return nil
        }
    }
}
