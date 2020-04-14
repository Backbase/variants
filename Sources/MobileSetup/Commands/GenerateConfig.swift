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
        try? generateConfig(path: Path("/usr/local/lib/mobile-setup/templates"))
        log("Generated mobile-setup.yml\n", indentationLevel: 2, force: true)
        log("Edit the file above before continuing\n\n", indentationLevel: 1, color: .purple, force: true)
    }
    
    private func generateConfig(path: Path) throws {
        guard path.absolute().exists else {
            throw CLI.Error(message: "Couldn't find template path")
        }
        try? Task.run(bash: "echo \(path.absolute())/mobile-setup-template.yml", directory: nil)
    }
}
