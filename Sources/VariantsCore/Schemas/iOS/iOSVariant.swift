//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import Foundation

// swiftlint:disable type_name

public struct iOSVariant: Variant {
    let name: String
    let versionName: String
    let versionNumber: Int
    let appIcon: String?
    let storeDestination: Destination
    let signing: iOSSigning?
    let custom: [CustomProperty]?
    private let bundleNamingOption: BundleNamingOption
     
    public var title: String { name }
    
    var configName: String {
        guard name != "default" else { return "" }
        return " " + name
    }
    
    var destinationProperty: CustomProperty {
        CustomProperty(
            name: "STORE_DESTINATION",
            value: storeDestination.rawValue,
            destination: .fastlane
        )
    }
    
    init(
        name: String, versionName: String, versionNumber: Int, appIcon: String?, storeDestination: String?,
        custom: [CustomProperty]?, idSuffix: String?, bundleID: String?, variantSigning: iOSSigning?, globalSigning: iOSSigning?)
    throws {
        self.name = name
        self.versionName = versionName
        self.versionNumber = versionNumber
        self.appIcon = appIcon
        self.storeDestination = try Self.parseDestination(name: name, destination: storeDestination) ?? .appStore
        self.signing = try Self.parseSigning(name: name, variantSigning: variantSigning, globalSigning: globalSigning)
        self.custom = custom
        self.bundleNamingOption = try Self.parseBundleConfiguration(name: name, idSuffix: idSuffix, bundleID: bundleID)
    }
    
    func makeBundleID(for target: iOSTarget) -> String {
        switch bundleNamingOption {
        case .idSuffix(let idSuffix):
            return target.bundleId + "." + idSuffix
        case .bundleID(let bundleID):
            return bundleID
        case .fromTarget:
            return target.bundleId
        }
    }
    
    func getDefaultValues(for target: iOSTarget) -> [(key: String, value: String)] {
        var customDictionary: [String: String] = [
            "V_APP_NAME": target.name + configName,
            "V_BUNDLE_ID": makeBundleID(for: target),
            "V_VERSION_NAME": versionName,
            "V_VERSION_NUMBER": String(versionNumber),
            "V_APP_ICON": appIcon ?? target.app_icon
        ]
       
        if signing?.matchURL != nil, let exportMethod = signing?.exportMethod {
            customDictionary["V_MATCH_PROFILE"] = "\(exportMethod.prefix) \(makeBundleID(for: target))"
        }
        
        custom?
            .filter { $0.destination == .project && !$0.isEnvironmentVariable }
            .forEach { customDictionary[$0.name] = $0.value }
        
        return customDictionary.sorted(by: {$0.key < $1.key})
    }
    
    private static func parseDestination(name: String, destination: String?) throws -> Destination? {
        guard let destinationString = destination else { return nil }
        
        guard let destination = Destination(rawValue: destinationString.lowercased()) else {
            throw RuntimeError(
                """
                Variant "\(name)" provided an invalid destination. Please choose between \
                \(Destination.allCases.map({ $0.rawValue }).joined(separator: ", "))
                """)
        }
        
        return destination
    }

    private static func parseSigning(name: String, variantSigning: iOSSigning?, globalSigning: iOSSigning?) throws -> iOSSigning? {
        if let variantSigning = variantSigning, let globalSigning = globalSigning {
            return try variantSigning ~ globalSigning
        } else if let variantSigning = variantSigning {
            return try variantSigning ~ nil
        } else if let globalSigning = globalSigning {
            return try globalSigning ~ nil
        } else {
            throw RuntimeError(
                """
                Variant "\(name)" doesn't contain a 'signing' configuration. \
                Create a global 'signing' configuration or make sure all variants have this property.
                """)
        }
    }
    
    private static func parseBundleConfiguration(name: String, idSuffix: String?, bundleID: String?) throws -> BundleNamingOption {
        guard name != "default" else { return .fromTarget }
        
        if let idSuffix = idSuffix, bundleID == nil {
            return .idSuffix(idSuffix)
        } else if idSuffix == nil, let bundleID = bundleID {
            return .bundleID(bundleID)
        } else {
            throw RuntimeError(
                """
                Variant "\(name)" have "id_suffix" and "bundle_id" configured at the same time or no \
                configuration were provided to any of them. Please provide only one of them per variant.
                """)
        }
    }
}

extension iOSVariant {
    enum Destination: String, Codable, CaseIterable, Equatable {
        case appCenter = "appcenter"
        case appStore = "appstore"
        case testFlight = "testflight"
    }
    
    enum BundleNamingOption: Codable {
        case idSuffix(String)
        case bundleID(String)
        case fromTarget
    }
}

/*
 * Used by `iOSConfiguration` decode variant from YAML spec
 * as dictionary `[String: UnnamediOSVariant]` and expose array `[iOSVariant]`.
 */
struct UnnamediOSVariant: Codable {
    let versionName: String
    let versionNumber: Int
    let appIcon: String?
    let idSuffix: String?
    let bundleID: String?
    let signing: iOSSigning?
    let custom: [CustomProperty]?
    let storeDestination: String?
    
    enum CodingKeys: String, CodingKey {
        case versionName = "version_name"
        case versionNumber = "version_number"
        case appIcon = "app_icon"
        case idSuffix = "id_suffix"
        case bundleID = "bundle_id"
        case signing
        case custom
        case storeDestination = "store_destination"
    }
}

extension UnnamediOSVariant {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        versionName = try values.decodeOrReadFromEnv(String.self, forKey: .versionName)
        versionNumber = try values.decodeOrReadFromEnv(Int.self, forKey: .versionNumber)
        appIcon = try values.decodeIfPresentOrReadFromEnv(String.self, forKey: .appIcon)
        idSuffix = try values.decodeIfPresentOrReadFromEnv(String.self, forKey: .idSuffix)
        bundleID = try values.decodeIfPresentOrReadFromEnv(String.self, forKey: .bundleID)
        signing = try values.decodeIfPresent(iOSSigning.self, forKey: .signing)
        custom = try values.decodeIfPresent([CustomProperty].self, forKey: .custom)
        storeDestination = try values.decodeIfPresentOrReadFromEnv(String.self, forKey: .storeDestination)
    }
}

extension iOSVariant {
    init(from unnamediOSVariant: UnnamediOSVariant, name: String, globalSigning: iOSSigning?) throws {
        try self.init(
            name: name,
            versionName: unnamediOSVariant.versionName,
            versionNumber: unnamediOSVariant.versionNumber,
            appIcon: unnamediOSVariant.appIcon,
            storeDestination: unnamediOSVariant.storeDestination,
            custom: unnamediOSVariant.custom,
            idSuffix: unnamediOSVariant.idSuffix,
            bundleID: unnamediOSVariant.bundleID,
            variantSigning: unnamediOSVariant.signing,
            globalSigning: globalSigning)
    }
}

// swiftlint:enable type_name
