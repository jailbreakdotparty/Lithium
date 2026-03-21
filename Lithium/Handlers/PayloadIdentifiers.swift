//
//  PayloadIdentifiers.swift
//  Lithium
//
//  Created by lunginspector on 3/10/26.
//

import Foundation
import PartyUI

enum ProfileName {
    static var applicationAccess: String { return "com.apple.applicationaccess" }
    static var sharedDeviceConfiguration: String { return "com.apple.shareddeviceconfiguration" }
    static var notificationSettings: String { return "com.apple.notificationsettings" }
}

struct StringPayloadItem: Identifiable, Codable, Equatable {
    var id: String { payloadKey }
    var payloadKey: String
    var payloadValue: String
    var icon: String = ""
    var label: String = ""
    
    enum CodingKeys: String, CodingKey {
        case payloadKey, payloadValue, icon, label
    }
}

struct BoolPayloadItem: Identifiable, Codable, Equatable, Hashable {
    var id: String { label }
    var icon: String = ""
    var label: String = ""
    var minSupportedVersion: Double = 0.0
    var maxSupportedVersion: Double = 99.0
    var infoType: ToggleInfoType = .none
    var alertMessage: String = ""
    var payloadKeys: [String]
    var payloadValue: Bool
    
    enum CodingKeys: String, CodingKey {
        case icon, label, minSupportedVersion, maxSupportedVersion, infoType, alertMessage, payloadKeys, payloadValue
    }
}
