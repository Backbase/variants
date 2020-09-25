//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

public struct Configuration: Codable {
    let ios: iOSConfiguration?
    let android: AndroidConfiguration?
}

public struct iOSConfiguration: Codable {
    public var xcodeproj: String
    public var targets: [String: iOSTarget]
    public var variants: [iOSVariant]
    
    var pbxproj: String {
        return xcodeproj+"/project.pbxproj"
        }
}

// iOS

public typealias NamedTarget = (key: String, value: iOSTarget)
public struct iOSTarget: Codable {
    let name: String
    let bundleId: String
    let app_icon: String
    let source: iOSSource
    
    enum CodingKeys: String, CodingKey {
        case name
        case app_icon
        case bundleId = "bundle_id"
        case source
    }
}

public struct iOSSource: Codable {
    let path: String
    let info: String
    let config: String
}

// Android

public struct AndroidConfiguration: Codable {
    public var path: String
    public var appProjectName: String
    public var variants: [AndroidVariant]
    public var signing: AndroidSigning
    public var custom: [String:String]

    enum CodingKeys: String, CodingKey {
        case path = "path"
        case appProjectName = "app_project_name"
        case variants = "variants"
        case signing = "signing"
        case custom = "custom"
    }
}

public struct AndroidVariant: Codable {
      public var name: String 
      public var versionName: String 
      public var versionCode: String 
      public var appIdentifier: String 
      public var appName: String 
      public var appcenterAppName: String 
      public var taskBuild: String 
      public var taskUnitTest: String 
      public var taskUitest: String

      enum CodingKeys: String, CodingKey {
        case name = "name"
        case versionName = "version_name"
        case versionCode = "version_code"
        case appIdentifier = "app_identifier"
        case appName = "app_name"
        case appcenterAppName = "appcenter_app_name"
        case taskBuild = "task_build"
        case taskUnitTest = "task_unittest"
        case taskUitest = "task_uitest"
      }
}

public struct AndroidSigning: Codable {
    public var keyAlias: String
    public var keyPassword: String
    public var storeFile: String
    public var storePassword: String


    enum CodingKeys: String, CodingKey {
        case keyAlias = "key_alias"
        case keyPassword = "key_password"
        case storeFile = "store_file"
        case storePassword = "store_password"
    }
}
