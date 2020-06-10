//
//  File.swift
//  
//
//  Created by Arthur Alves on 10/06/2020.
//

import Foundation
import SwiftCLI

extension Command {
    func fail(with message: String) {
        Logger.shared.logError("❌ ", item: message)
        exit(1)
    }
}
