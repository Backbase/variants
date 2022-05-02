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
    private let idSuffix: String?
    private let bundleID: String?
     
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
    
    init(from unnamediOSVariant: UnnamediOSVariant, name: String, globalSigning: iOSSigning?) throws {
        guard globalSigning != nil || unnamediOSVariant.signing != nil else {
            throw RuntimeError(
                """
                Variant "\(name)" doesn't contain a 'signing' configuration. \
                Create a global 'signing' configuration or make sure all variants have this property.
                """)
        }
        
        if let localSigning = unnamediOSVariant.signing, let globalSigning = globalSigning {
            self.signing = try localSigning ~ globalSigning
        } else if let localSigning = unnamediOSVariant.signing {
            self.signing = localSigning
        } else {
            self.signing = globalSigning
        }
        
        let hasIDSuffixAndBundleID = unnamediOSVariant.idSuffix != nil && unnamediOSVariant.bundleId != nil
        let hasNoIDSuffixOrBundleID = unnamediOSVariant.idSuffix == nil && unnamediOSVariant.bundleId == nil
        guard (!hasIDSuffixAndBundleID && !hasNoIDSuffixOrBundleID) || name == "default" else {
            throw RuntimeError(
                """
                Variant "\(name)" have "id_suffix" and "bundle_id" configured at the same time or no \
                configuration were provided to any of them. Please provide only one of them per variant.
                """)
        }
        
        self.name = name
        self.versionName = unnamediOSVariant.versionName
        self.versionNumber = unnamediOSVariant.versionNumber
        self.appIcon = unnamediOSVariant.appIcon
        self.storeDestination = try Self.parseDestination(name: name, destination: unnamediOSVariant.storeDestination) ?? .appStore
        self.custom = unnamediOSVariant.custom
        self.idSuffix = unnamediOSVariant.idSuffix
        self.bundleID = unnamediOSVariant.bundleId
    }
    
    func makeBundleID(for target: iOSTarget) -> String {
        guard bundleID == nil else { return bundleID! }
        guard name != "default" else { return target.bundleId }
        
        return target.bundleId + (idSuffix ?? "")
    }
    
    func getDefaultValues(for target: iOSTarget) -> [String: String] {
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
        
        return customDictionary
    }
    
    private static func parseDestination(name: String, destination: String?) throws -> Destination? {
        guard let destinationString = destination else { return nil }
        
        guard let destination = Destination(rawValue: destinationString) else {
            throw RuntimeError(
                """
                Variant "\(name)" provided an invalid destination. Please choose between \
                \(Destination.allCases.map({ $0.rawValue }).joined(separator: ", "))
                """)
        }
        
        return destination
    }
}

extension iOSVariant {
    enum Destination: String, Codable, CaseIterable {
        case appCenter = "appcenter"
        case appStore = "appstore"
        case testFlight = "testflight"
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
    let bundleId: String?
    let signing: iOSSigning?
    let custom: [CustomProperty]?
    let storeDestination: String?
    
    enum CodingKeys: String, CodingKey {
        case versionName = "version_name"
        case versionNumber = "version_number"
        case appIcon = "app_icon"
        case idSuffix = "id_suffix"
        case bundleId = "bundle_id"
        case signing
        case custom
        case storeDestination = "store_destination"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        versionName = try values.decodeOrReadFromEnv(String.self, forKey: .versionName)
        versionNumber = try values.decodeOrReadFromEnv(Int.self, forKey: .versionNumber)
        appIcon = try values.decodeIfPresentOrReadFromEnv(String.self, forKey: .appIcon)
        idSuffix = try values.decodeIfPresentOrReadFromEnv(String.self, forKey: .idSuffix)
        bundleId = try values.decodeIfPresentOrReadFromEnv(String.self, forKey: .bundleId)
        signing = try values.decodeIfPresent(iOSSigning.self, forKey: .signing)
        custom = try values.decodeIfPresent([CustomProperty].self, forKey: .custom)
        storeDestination = try values.decodeIfPresentOrReadFromEnv(String.self, forKey: .storeDestination)
    }
}
