//
//  RestrictionsArray.swift
//  Lithium
//
//  Created by lunginspector on 6/30/26.
//

import Foundation
import PartyUI

struct InfoItem {
    var type: ToggleInfoType
    var title: String
    var message: String
}

struct RestrictionItem: Identifiable {
    var id = UUID()
    var name: String
    var info: InfoItem = InfoItem(type: .none, title: "", message: "")
    var keys: [String]
}

struct RestrictionSection: Identifiable {
    var id = UUID()
    var name: String
    var icon: String
    var minVrs = 0.0
    var maxVrs = 99.9
    var items: [RestrictionItem]
}

let restrictionsArray: [RestrictionSection] = [
    RestrictionSection(name: "Apps", icon: "app", items: [
        RestrictionItem(name: "App Store", keys: ["allowUIAppInstallation"]),
        RestrictionItem(name: "App Installation & Removal", keys: ["allowAppInstallation", "allowAppRemoval"]),
        RestrictionItem(name: "In-App Purchases", keys: ["allowInAppPurchases"]),
        RestrictionItem(name: "Apple Music Services", keys: ["allowMusicService", "allowRadioService"]),
        RestrictionItem(name: "Bookstore", info: InfoItem(type: .warning, title: "Warning", message: "If you are on iOS 26.2db1 or earlier and you use BookRestore-related exploit tools (e.g. Nugget), do not toggle this feature off! It will break your ability to download books from the book store which is required for the exploit to work."), keys: ["allowBookstore"])
    ]),

    RestrictionSection(name: "System Features", icon: "camera", items: [
        RestrictionItem(name: "Screen Capture", keys: ["allowScreenShot"]),
        RestrictionItem(name: "Siri", keys: ["allowAssistant"]),
        RestrictionItem(name: "Game Center", keys: ["allowGameCenter"]),
        RestrictionItem(name: "Screen Time", info: InfoItem(type: .warning, title: "Warning", message: "I'm not responsible if you get in trouble for disabling this feature. Use at your own risk."), keys: ["allowEnablingRestrictions"]),
        RestrictionItem(name: "Safari", keys: ["allowSafari"]),
        RestrictionItem(name: "Camera", keys: ["allowCamera"])
    ]),

    RestrictionSection(name: "Sharing & External Features", icon: "iphone.radiowaves.left.and.right", items: [
        RestrictionItem(name: "Apple Watch Pairing", info: InfoItem(type: .warning, title: "Warning", message: "If you have any Apple Watches paired to this iPhone, toggling this off will cause the watch to get unpaired and factory reset."), keys: ["allowPairedWatch"]),
        RestrictionItem(name: "Proximity Setup", keys: ["allowProximitySetupToNewDevice"]),
        RestrictionItem(name: "NFC", info: InfoItem(type: .warning, title: "Warning", message: "If you have any cards or passes that rely on NFC (tapping your phone to the reader), this will break the ability to use them if toggled off."), keys: ["allowNFC"]),
        RestrictionItem(name: "AirDrop", keys: ["allowAirDrop"])
    ]),

    RestrictionSection(name: "Apple Intelligence", icon: "apple.intelligence", minVrs: 18.1, items: [
        RestrictionItem(name: "Genmoji", keys: ["allowGenmoji"]),
        RestrictionItem(name: "Image Wand", keys: ["allowImageWand"]),
        RestrictionItem(name: "Mail Smart Replies", keys: ["allowMailSmartReplies"]),
        RestrictionItem(name: "Mail Summaries", keys: ["allowMailSummary"]),
        RestrictionItem(name: "Personalized Handwriting Results", keys: ["allowPersonalizedHandwritingResults"]),
        RestrictionItem(name: "Safari Summary", keys: ["allowSafariSummary"]),
        RestrictionItem(name: "Visual Intelligence Summary", keys: ["allowVisualIntelligenceSummary"]),
        RestrictionItem(name: "Writing Tools", keys: ["allowWritingTools"])
    ])
]
