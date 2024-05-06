//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

enum RawIdentity {
    case teamName(_ name: String)
    case signingIdentity(type: CertificateType, teamName: String)
    case invalidFormat(_ name: String)
    case emptyName

    enum CertificateType: String {
        case appleDevelopment = "Apple Development"
        case appleDistribution = "Apple Distribution"
        case iPhoneDevelopment = "iPhone Development"
        case iPhoneDistribution = "iPhone Distribution"
    }

    static func decode(_ teamName: String) -> RawIdentity {
        let split = teamName.split(separator: ":")

        switch split.count {
        case 0:
            return .emptyName
        case 1:
            return .teamName(teamName)
        case 2:
            if let certType = CertificateType(rawValue: String(split.first!)) {
                return .signingIdentity(type: certType, teamName: String(split.last!.dropFirst()))
            } else {
                return .invalidFormat(teamName)
            }
        default:
            return .invalidFormat(teamName)
        }
    }
}
