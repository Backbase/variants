//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Balazs Toth
//

import Foundation

struct Bash {
    var command: String
    var arguments: [String]
    
    enum Stream {
        case stdout
        case stderr
    }
    
    init(_ command: String, arguments: String...) {
        self.command = command
        self.arguments = arguments
    }
    
    func run() throws {
        _ = try capture()
    }
    
    func capture(stream: Stream = .stdout) throws -> String? {
        guard var bashCommand = try execute(command: "/bin/bash", arguments: ["-l", "-c", "which \(command)"]) else {
            throw RuntimeError("\(command) not found")
        }
        bashCommand = bashCommand.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if let output = try execute(command: bashCommand, arguments: arguments, stream: stream) {
            // `dropLast()` is required as the output always contains a new line (`\n`) at the end.
            return String(output.dropLast())
        }
        return nil
    }
    
    // MARK: - Private
    
    private func execute(command: String, arguments: [String] = [], stream: Stream = .stdout) throws -> String? {
        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.arguments = arguments
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        if #available(OSX 10.13, *) {
            process.executableURL = URL(fileURLWithPath: command)
            try process.run()
        } else {
            process.launchPath = command
            process.launch()
        }
        
        switch stream {
        case .stdout:
            let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            let stdout = String(data: stdoutData, encoding: .utf8)
            return stdout
        case .stderr:
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            let stderr = String(data: stderrData, encoding: .utf8)
            return stderr
        }
    }
}
