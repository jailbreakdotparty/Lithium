//
//  ViewIdentifiers.swift
//  Lithium
//
//  Created by lunginspector on 3/10/26.
//

import Foundation

struct ItemRow: Identifiable, Equatable, Sendable {
    var id: String { label }
    var icon: String
    var label: String
    var minSupportedVersion: Double = 0.0
    var maxSupportedVersion: Double = 99.9
    var tweakArray: [BoolPayloadItem]
}

enum ProfileName {
    static var restrictionFlags: String { return "com.apple.applicationaccess" }
    static var footnote: String { return "com.apple.shareddeviceconfiguration" }
}
