//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import XCTest
import class Foundation.Bundle

// swiftlint:disable line_length

final class InitCommandTests: XCTestCase {
    func testUsage_help() throws {
        let arguments = ["init", "--help"]
        
        let expectedOutput = "OVERVIEW: Generate spec file - variants.yml\n\nUSAGE: variants init [--platform <platform>] [--timestamps] [--verbose]\n\nOPTIONS:\n  -p, --platform <platform>\n                          \'ios\' or \'android\' \n  -t, --timestamps        Show timestamps. \n  -v, --verbose           Log tech details for nerds \n  --version               Show the version.\n  -h, --help              Show help information.\n\n"

        let output = try CLIExecutor.shared.run(with: arguments)
        XCTAssertEqual(output, expectedOutput)
    }
    
    #warning("Test 'testUsage_noExtraArguments' will always fail when running from Xcode.")
    func testUsage_noExtraArguments() throws {
        let arguments = ["init"]
        
        let expectedOutput = "\u{1B}[1;0m\u{1B}[0;0m--------------------------------------------------------------------------------------\u{1B}[0;0m\n\u{1B}[1;49;36m$ \u{1B}[0;49;36mvariants init\u{1B}[0;0m\n\u{1B}[1;0m\u{1B}[0;0m--------------------------------------------------------------------------------------\u{1B}[0;0m\n\u{1B}[1;32m📝  \u{1B}[0;32mVariants\' spec generated with success at path \'./variants.yml\'\u{1B}[0;0m\n\u{1B}[1;33m⚠️  \u{1B}[0;33mWe were unable to populate the following fields in the \'./variants.yml\' spec:\n\n    * ios.targets.fooTarget\n    * ios.targets.fooTarget.name\n    * ios.targets.fooTarget.bundle_id\n    * ios.targets.fooTarget.test_target\n    * ios.targets.fooTarget.app_icon\n    * ios.targets.fooTarget.source.path\n    * ios.targets.fooTarget.source.info\n\nPlease replace their placeholders manually.\n\u{1B}[0;0m\n"

        let output = try CLIExecutor.shared.run(with: arguments)
        XCTAssertEqual(output, expectedOutput)
    }
    
    func testInit_unknownArgument() throws {
        let arguments = ["init", "unknown-argument"]
        
        let expectedOutput =
            """
            Error: Unexpected argument \'unknown-argument\'
            Usage: variants init [--platform <platform>] [--timestamps] [--verbose]
              See \'variants init --help\' for more information.

            """
        
        let output = try CLIExecutor.shared.run(with: arguments)
        XCTAssertEqual(output, expectedOutput)
    }
    
    static var allTests = [
        ("testUsage_help", testUsage_help),
        ("testUsage_noExtraArguments", testUsage_noExtraArguments),
        ("testInit_unknownArgument", testInit_unknownArgument)
    ]
}
