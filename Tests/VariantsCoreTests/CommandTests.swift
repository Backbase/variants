//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Oleg Baidalka
//

import XCTest

@testable import VariantsCore
import SwiftUI

final class CommandTests: XCTestCase {
    
    let defaultPlatform = ""
    let defaultSpec = ""
    
    func testInitializerCommand() throws {
        var command = try Initializer.parse([])
        XCTAssertEqual(command.platform, defaultPlatform)
        XCTAssertFalse(command.showTimestamps)
        XCTAssertFalse(command.verbose)
        XCTAssertNoThrow(try command.validate())
    }
    
    func testSetupCommand() throws {
        var command = try Setup.parse([])
        XCTAssertEqual(command.platform, defaultPlatform)
        XCTAssertNotEqual(command.spec, defaultSpec)
        XCTAssertFalse(command.skipFastlane)
        XCTAssertFalse(command.showTimestamps)
        XCTAssertFalse(command.verbose)
        XCTAssertNoThrow(try command.validate())
    }

    func testSwitchCommand() throws {
        var command = try Switch.parse([])
        XCTAssertEqual(command.platform, defaultPlatform)
        XCTAssertEqual(command.variant, "default")
        XCTAssertNotEqual(command.spec, defaultSpec)
        XCTAssertFalse(command.showTimestamps)
        XCTAssertFalse(command.verbose)
        XCTAssertNoThrow(try command.validate())
    }

    func testListCommand() throws {
        var command = try List.parse([])
        XCTAssertEqual(command.platform, defaultPlatform)
        XCTAssertNotEqual(command.spec, defaultSpec)
        XCTAssertFalse(command.showTimestamps)
        XCTAssertFalse(command.verbose)
        XCTAssertNoThrow(try command.validate())
    }
}
