//
//  iOSExtension.swift
//  VariantsCore
//
//  Created by Gabriel Rodrigues Minucci on 24/01/2025.
//

import Foundation

// swiftlint:disable:next type_name
public struct iOSExtension: Codable {
    let name: String
    let bundleNamingOption: BundleNamingOption
    let signed: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case bundleID = "bundle_id"
        case bundleSuffix = "bundle_suffix"
        case signed
    }

    enum BundleNamingOption: Codable {
        case explicit(String)
        case suffix(String)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        signed = try container.decode(Bool.self, forKey: .signed)

        let bundleID = try container.decodeIfPresent(String.self, forKey: .bundleID)
        let bundleSuffix = try container.decodeIfPresent(String.self, forKey: .bundleSuffix)
        
        if let bundleID, bundleSuffix == nil {
            bundleNamingOption = .explicit(bundleID)
        } else if let bundleSuffix, bundleID == nil {
            bundleNamingOption = .suffix(bundleSuffix)
        } else {
            throw RuntimeError(
                """
                Target extension "\(name)" have "bundle_suffix" and "bundle_id" configured at the same time or no \
                configuration were provided to any of them. Please provide only one of them per target extension.
                """)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(signed, forKey: .signed)

        switch bundleNamingOption {
        case .explicit(let bundleID):
            try container.encode(bundleID, forKey: .bundleID)
        case .suffix(let bundleSuffix):
            try container.encode(bundleSuffix, forKey: .bundleSuffix)
        }
    }

    func makeBundleID(variant: iOSVariant, target: iOSTarget) -> String {
        switch bundleNamingOption {
        case .explicit(let bundleID):
            return bundleID
        case .suffix(let bundleSuffix):
            return variant.makeBundleID(for: target).appending(".\(bundleSuffix)")
        }
    }
}
