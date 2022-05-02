//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation

public struct AndroidVariant: Variant {
    let name: String
    let versionName: String
    let versionCode: String
    let idSuffix: String?
    let taskBuild: String
    let taskUnitTest: String
    let taskUitest: String
    let custom: [CustomProperty]?
    internal let store_destination: String?
    
    var configName: String {
        switch name {
        case "default":
            return ""
        default:
            return " "+name
        }
    }
    
    var configIdSuffix: String {
        switch name {
        case "default":
            return ""
        default:
            return idSuffix != nil ? "."+idSuffix! : ""
        }
    }
    
    var destinationProperty: CustomProperty {
        var defaultDestination: Destination = .playStore
        if
            let storeDestination = store_destination,
            let destination = Destination(rawValue: storeDestination.lowercased()) {
            defaultDestination = destination
        }
        return CustomProperty(
            name: "STORE_DESTINATION",
            value: defaultDestination.rawValue,
            destination: .fastlane
        )
    }
}

extension AndroidVariant {
    enum Destination: String, Codable {
        case appCenter = "appcenter"
        case playStore = "playstore"
    }
}

/*
 * Used by `AndroidConfiguration` decode variant from YAML spec
 * as dictionary `[String: UnnamedAndroidVariant]` and expose array `[AndroidVariant]`.
 */
struct UnnamedAndroidVariant: Codable {
    let versionName: String
    let versionCode: String
    let idSuffix: String?
    let taskBuild: String
    let taskUnitTest: String
    let taskUitest: String
    let custom: [CustomProperty]?
    internal let store_destination: String?
    
    enum CodingKeys: String, CodingKey {
        case versionName = "version_name"
        case versionCode = "version_code"
        case idSuffix = "id_suffix"
        case taskBuild = "task_build"
        case taskUnitTest = "task_unittest"
        case taskUitest = "task_uitest"
        case custom = "custom"
        case store_destination = "store_destination"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        versionCode = try values.decodeOrReadFromEnv(String.self, forKey: .versionCode)
        versionName = try values.decodeOrReadFromEnv(String.self, forKey: .versionName)
        idSuffix = try values.decodeIfPresentOrReadFromEnv(String.self, forKey: .idSuffix)
        taskBuild = try values.decodeOrReadFromEnv(String.self, forKey: .taskBuild)
        taskUnitTest = try values.decodeOrReadFromEnv(String.self, forKey: .taskUnitTest)
        taskUitest = try values.decodeOrReadFromEnv(String.self, forKey: .taskUitest)
        custom = try values.decodeIfPresent([CustomProperty].self, forKey: .custom)
        store_destination = try values.decodeIfPresentOrReadFromEnv(String.self, forKey: .store_destination)
    }
    
}
