//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import XCTest
import PathKit
@testable import VariantsCore

class PlatformDetectorTests: XCTestCase {
    let xcodeProjectPath = Path("./Test.xcodeproj")
    let gradleProjectPath = Path("./build.gradle")
    
    func testAvailablePlatforms_ios() {
        XCTAssertNoThrow(try cleanup())
        
        // Ensure '.xcodeproj' exists
        if !xcodeProjectPath.exists {
            XCTAssertNoThrow(try xcodeProjectPath.mkpath())
        }
        XCTAssertTrue(xcodeProjectPath.exists)
        XCTAssertTrue(xcodeProjectPath.isDirectory)
        
        let availablePlatforms = PlatformDetector.availablePlatforms
        
        XCTAssertEqual(availablePlatforms.count, 1)
        XCTAssertEqual(availablePlatforms.first, .ios)
    }
    
    func testAvailablePlatforms_android() {
        XCTAssertNoThrow(try cleanup())
        
        // Ensure 'build.gradle' exists
        if !gradleProjectPath.exists {
            XCTAssertNoThrow(try gradleProjectPath.mkpath())
        }
        XCTAssertTrue(gradleProjectPath.exists)
        
        let availablePlatforms = PlatformDetector.availablePlatforms
        
        XCTAssertEqual(availablePlatforms.count, 1)
        XCTAssertEqual(availablePlatforms.first, .android)
    }
    
    func testAvailablePlatforms_multiple() {
        XCTAssertNoThrow(try cleanup())
        
        // Ensure 'build.gradle' exists
        if !gradleProjectPath.exists {
            XCTAssertNoThrow(try gradleProjectPath.mkpath())
        }
        XCTAssertTrue(gradleProjectPath.exists)
        
        // Ensure '.xcodeproj' exists
        if !xcodeProjectPath.exists {
            XCTAssertNoThrow(try xcodeProjectPath.mkpath())
        }
        XCTAssertTrue(xcodeProjectPath.exists)
        
        let availablePlatforms = PlatformDetector.availablePlatforms
        
        XCTAssertEqual(availablePlatforms.count, 2)
        XCTAssertTrue(availablePlatforms.contains(.ios))
        XCTAssertTrue(availablePlatforms.contains(.android))
    }
    
    func testDetectPlatform_xcodeProj() {
        XCTAssertNoThrow(try cleanup())
        let platform = ""
        
        if !xcodeProjectPath.exists {
            XCTAssertNoThrow(try xcodeProjectPath.mkpath())
        }
       
        XCTAssertTrue(xcodeProjectPath.exists)
        XCTAssertTrue(xcodeProjectPath.isDirectory)
        
        XCTAssertNoThrow(try PlatformDetector.detect(fromArgument: platform))
        
        let detectedPlatform = try? PlatformDetector.detect(fromArgument: platform)
        
        XCTAssertNotNil(detectedPlatform)
        XCTAssertEqual(detectedPlatform, .ios)
    }
    
    func testDetectPlatform_gradleProj() {
        XCTAssertNoThrow(try cleanup())
        let platform = ""
        
        if !gradleProjectPath.exists {
            XCTAssertNoThrow(try gradleProjectPath.mkpath())
        }
       
        XCTAssertTrue(gradleProjectPath.exists)
        
        XCTAssertNoThrow(try PlatformDetector.detect(fromArgument: platform))
        
        let detectedPlatform = try? PlatformDetector.detect(fromArgument: platform)
        
        XCTAssertNotNil(detectedPlatform)
        XCTAssertEqual(detectedPlatform, .android)
    }
    
    func testDetectPlatform_couldNotDetectPlatform() {
        XCTAssertNoThrow(try cleanup())
        let platform = ""
       
        XCTAssertTrue(!xcodeProjectPath.exists)
        XCTAssertTrue(!gradleProjectPath.isDirectory)
        
        XCTAssertThrowsError(try PlatformDetector.detect(fromArgument: platform),
                             "No .xcodeproj nor build.gradle should be found") { (error) in
            XCTAssertEqual(error as? PlatformDetector.Errors, PlatformDetector.Errors.couldNotDetectPlatform)
            if let detectionError = error as? PlatformDetector.Errors {
                XCTAssertEqual(detectionError.errorDescription, """
                    ❌ Could not find an Android or Xcode project in your working directory.
                    """)
            }
        }
    }
    
    func testDetectPlatform_multiplePlatformsAvailable() {
        XCTAssertNoThrow(try cleanup())
        let platform = ""
       
        // Ensure 'build.gradle' exists
        if !gradleProjectPath.exists {
            XCTAssertNoThrow(try gradleProjectPath.mkpath())
        }
        XCTAssertTrue(gradleProjectPath.exists)
        
        // Ensure '.xcodeproj' exists
        if !xcodeProjectPath.exists {
            XCTAssertNoThrow(try xcodeProjectPath.mkpath())
        }
        XCTAssertTrue(xcodeProjectPath.exists)
        
        XCTAssertThrowsError(try PlatformDetector.detect(fromArgument: platform),
                             "Both .xcodeproj and build.gradle should be found") { (error) in
            XCTAssertEqual(error as? PlatformDetector.Errors, PlatformDetector.Errors.multiplePlatformsAvailable)
            if let detectionError = error as? PlatformDetector.Errors {
                XCTAssertEqual(detectionError.errorDescription, """
                    ❌ Found an Android and Xcode project in your working directory.
                    Please specify the platform you want using `--platform <value>`
                    """)
            }
        }
    }
    
    private func cleanup() throws {
        if xcodeProjectPath.exists {
            try xcodeProjectPath.delete()
        }
        
        if gradleProjectPath.exists {
            try gradleProjectPath.delete()
        }
    }
}
