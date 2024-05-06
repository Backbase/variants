//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Balazs Toth
//

import Foundation
import PathKit

struct Bash {
    var command: String
    var arguments: [String]
    var standardInput: String?

    init(_ command: String, standardInput: String? = nil, arguments: String...) {
        self.command = command
        self.standardInput = standardInput
        self.arguments = arguments
    }

    func run() throws {
        _ = try capture()
    }

    func capture() throws -> String? {
        let bashCommand = try fullPath(command: command)
        if let output = try execute(command: bashCommand, arguments: arguments) {
            // `dropLast()` is required as the output always contains a new line (`\n`) at the end.
            return String(output.dropLast())
        }
        return nil
    }

    func pipe(_ bashCommand: Bash) throws -> Bash {
        let output = try self.capture()
        var command = bashCommand
        command.standardInput = output
        return command
    }

    // MARK: - Private
    
    private func fullPath(command: String) throws -> String {
        let bash = Bash(command, arguments: "")
        guard var bashCommand = try bash.execute(command: "/bin/bash", arguments: ["-l", "-c", "which \(command)"]) else {
            throw RuntimeError("\(command) not found")
        }
        bashCommand = bashCommand.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        return bashCommand
    }

    private func execute(command: String, arguments: [String] = []) throws -> String? {
        let process = Process()
        let pipe = Pipe()

        process.arguments = arguments
        process.standardOutput = pipe

        /*
         * `standardInput` needs to be written to a file in order to be used by a Process.
         */
        if let stdin = standardInput {
            let path = try Path.processUniqueTemporary().safeJoin(path: Path(stringLiteral: "stdin"))
            try path.write(stdin.data(using: .utf8)!)
            process.standardInput = FileHandle(forReadingAtPath: path.absolute().string)
        }

        if #available(OSX 10.13, *) {
            process.executableURL = URL(fileURLWithPath: command)
            try process.run()
        } else {
            process.launchPath = command
            process.launch()
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        return output
    }
}
