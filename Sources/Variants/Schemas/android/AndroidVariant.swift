//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation

public struct AndroidVariant: Codable {
    let name: String
    let versionName: String
    let versionCode: String
    let idSuffix: String?
    let taskBuild: String
    let taskUnitTest: String
    let taskUitest: String
    let custom: [CustomProperty]?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case versionName = "version_name"
        case versionCode = "version_code"
        case idSuffix = "id_suffix"
        case taskBuild = "task_build"
        case taskUnitTest = "task_unittest"
        case taskUitest = "task_uitest"
        case custom = "custom"
    }
    
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
}
