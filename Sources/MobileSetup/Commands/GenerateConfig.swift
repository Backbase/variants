//
//  File.swift
//  
//
//  Created by Arthur Alves on 14/04/2020.
//

import Foundation
import PathKit
import SwiftCLI

final class GenerateConfig: Command, VerboseLogger {
    // --------------
    // MARK: Command information
    
    let name: String = "init"
    let shortDescription: String = "Generate project yml file that is used by MobileSetup and XcodeGen"
    
    public func execute() throws {
        log("--------------------------------------------", indentationLevel: 1, force: true)
        log("Running: mobile-setup init", indentationLevel: 1, force: true)
        log("--------------------------------------------", indentationLevel: 1, force: true)
        log("Generated mobile-setup.yml\n", indentationLevel: 2, force: true)
        log("Edit the file above before continuing\n\n", indentationLevel: 1, color: .purple, force: true)
    }
}
