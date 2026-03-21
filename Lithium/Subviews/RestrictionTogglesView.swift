//
//  RestrictionTogglesView.swift
//  Lithium
//
//  Created by lunginspector on 3/7/26.
//

import SwiftUI
import PartyUI

struct RestrictionTogglesView: View {
    // i'm sorry for having it right here but i also don't really care at the same time. lemin does it this way too so shut up.
    @State private var restrictionTogglesArray: [ItemRow] = [
        ItemRow(icon: "app", label: "Apps", tweakArray: [
            BoolPayloadItem(icon: "bag", label: "App Store", payloadKeys: ["allowUIAppInstallation"], payloadValue: true),
            BoolPayloadItem(icon: "plus.app", label: "App Installation & Removal", payloadKeys: ["allowAppInstallation", "allowAppRemoval"], payloadValue: true),
            BoolPayloadItem(icon: "person.text.rectangle", label: "In-App Purchases", payloadKeys: ["allowInAppPurchases"], payloadValue: true),
            BoolPayloadItem(icon: "music.note.list", label: "Apple Music Services", payloadKeys: ["allowMusicService", "allowRadioService"], payloadValue: true),
            BoolPayloadItem(icon: "book", label: "Bookstore", infoType: .warning, alertMessage: "Warning: If you are on iOS 26.2db1 or earlier and you use BookRestore-related exploit tools (e.g. Nugget), do not toggle this feature off! It will break your ability to download books from the book store which is required for the exploit to work.", payloadKeys: ["allowBookstore"], payloadValue: true)
        ]),
        ItemRow(icon: "camera", label: "System Features", tweakArray: [
            BoolPayloadItem(icon: "crop", label: "Screen Capture", payloadKeys: ["allowScreenShot"], payloadValue: true),
            BoolPayloadItem(icon: "waveform", label: "Siri", payloadKeys: ["allowAssistant"], payloadValue: true),
            BoolPayloadItem(icon: "gamecontroller", label: "Game Center", payloadKeys: ["allowGameCenter"], payloadValue: true),
            BoolPayloadItem(icon: "hourglass", label: "Screen Time", infoType: .warning, alertMessage: "I'm not responsible if you get in trouble for disabling this feature. Use at your own risk.", payloadKeys: ["allowEnablingRestrictions"], payloadValue: true),
            BoolPayloadItem(icon: "safari", label: "Safari", payloadKeys: ["allowSafari"], payloadValue: true),
            BoolPayloadItem(icon: "camera", label: "Camera", payloadKeys: ["allowCamera"], payloadValue: true)
        ]),
        ItemRow(icon: "iphone.radiowaves.left.and.right", label: "Sharing & External Features", tweakArray: [
            BoolPayloadItem(icon: "applewatch", label: "Apple Watch Pairing", infoType: .warning, alertMessage: "Warning: If you have any Apple Watches paired to this iPhone, toggling this off will cause the watch to get unpaired and factory reset.", payloadKeys: ["allowPairedWatch"], payloadValue: true),
            BoolPayloadItem(icon: "checkmark.rectangle.portrait", label: "Proximity Setup", payloadKeys: ["allowProximitySetupToNewDevice"], payloadValue: true),
            BoolPayloadItem(icon: "dollarsign.square", label: "NFC", infoType: .warning, alertMessage: "Warning: If you have any cards or passes that rely on NFC (tapping your phone to the reader), this will break the ability to use them if toggled off.", payloadKeys: ["allowNFC"], payloadValue: true),
            BoolPayloadItem(icon: "dot.radiowaves.left.and.right", label: "AirDrop", payloadKeys: ["allowAirDrop"], payloadValue: true)
        ]),
        ItemRow(icon: "apple.intelligence", label: "Apple Intelligence", minSupportedVersion: 18.1, tweakArray: [
            BoolPayloadItem(icon: "smiley", label: "Genmoji", payloadKeys: ["allowGenmoji"], payloadValue: true),
            BoolPayloadItem(icon: "wand.and.rays", label: "Image Wand", payloadKeys: ["allowImageWand"], payloadValue: true),
            BoolPayloadItem(icon: "arrowshape.turn.up.left", label: "Mail Smart Replies", payloadKeys: ["allowMailSmartReplies"], payloadValue: true),
            BoolPayloadItem(icon: "text.insert", label: "Mail Summaries", payloadKeys: ["allowMailSummary"], payloadValue: true),
            BoolPayloadItem(icon: "pencil.and.outline", label: "Personalized Handwriting Results", payloadKeys: ["allowPersonalizedHandwritingResults"], payloadValue: true),
            BoolPayloadItem(icon: "doc.richtext", label: "Safari Summary", payloadKeys: ["allowSafariSummary"], payloadValue: true),
            BoolPayloadItem(icon: "sparkle.magnifyingglass", label: "Visual Intelligence Summary", payloadKeys: ["allowVisualIntelligenceSummary"], payloadValue: true),
            BoolPayloadItem(icon: "apple.writing.tools", label: "Writing Tools", payloadKeys: ["allowWritingTools"], payloadValue: true)
        ])
    ]
    @State private var showDebugSheet: Bool = false
    @State private var enableDelayedOTA: Bool = false
    @State private var softwareUpdateDelayInt: Int = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Device Updates", icon: "square.and.arrow.down")) {
                    PlainToggle(icon: "clock", label: "Delay OTA Updates", infoType: .info, infoTitle: "Delay OTA Updates", infoMessage: "Note that this feature only supports delayed OTAs up to 90 days. Also, you cannot downgrade your device with this feature (e.g. delay from 26.3.1 → 26.2).", isOn: $enableDelayedOTA)
                    if enableDelayedOTA {
                        HStack {
                            LabeledContent("Number of Days") {
                                TextField("Software Update Delay", value: $softwareUpdateDelayInt, format: .number)
                                    .keyboardType(.numberPad)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: softwareUpdateDelayInt) { newValue in
                                        softwareUpdateDelayInt = min(max(newValue, 0), 90)
                                    }
                            }
                        }
                    }
                }
                ForEach($restrictionTogglesArray) { $section in
                    Section(header: HeaderLabel(text: section.label, icon: section.icon)) {
                        ForEach($section.tweakArray) { $item in
                            PlainToggle(icon: item.icon, label: item.label, infoType: item.infoType, infoTitle: "Warning: Disable \(item.label)", infoMessage: item.alertMessage, isOn: $item.payloadValue)
                        }
                    }
                }
            }
            .navigationTitle("Restriction Toggles")
            .toolbar {
                if weOnADebugBuild {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showDebugSheet.toggle()
                        }) {
                            Image(systemName: "ant")
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button(action: {
                        Haptic.shared.play(.soft)
                        installProfile(profileName: ProfileName.applicationAccess)
                    }) {
                        ButtonLabel(text: "Install Profile", icon: "party.popper")
                    }
                    .buttonStyle(TranslucentButtonStyle(color: .green))
                }
                .modifier(OverlayBackground(stickBottomPadding: true))
            }
            .sheet(isPresented: $showDebugSheet) {
                ProfileDebugSheet(profileName: ProfileName.applicationAccess)
            }
        }
        .onChange(of: restrictionTogglesArray) { newValue in
            updateRestrictionTogglesPlist()
        }
        .onChange(of: enableDelayedOTA) { newValue in
            if newValue == false {
                softwareUpdateDelayInt = 0
            }
            updateRestrictionTogglesPlist()
        }
        .onChange(of: softwareUpdateDelayInt) { newValue in
            updateRestrictionTogglesPlist()
        }
        .onAppear {
            getRestrictionTogglesArrayFromPlist()
        }
    }
    func getRestrictionTogglesArrayFromPlist() {
        let payloadContentDict = getPCDictFromProfile(profileName: ProfileName.applicationAccess)
        
        for row in restrictionTogglesArray.indices {
            for item in restrictionTogglesArray[row].tweakArray.indices {
                let tweakKey = restrictionTogglesArray[row].tweakArray[item].payloadKeys.first ?? ""
                let plistValue = payloadContentDict[tweakKey] as? Bool ?? false
                
                restrictionTogglesArray[row].tweakArray[item].payloadValue = plistValue
            }
        }
        
        softwareUpdateDelayInt = payloadContentDict["enforcedSoftwareUpdateDelay"] as? Int ?? 0
        enableDelayedOTA = payloadContentDict["forceDelayedSoftwareUpdates"] as? Bool ?? false
    }
    func updateRestrictionTogglesPlist() {
        let restrictionTogglesArrayFlat = restrictionTogglesArray.flatMap { $0.tweakArray }
        
        var restrictionTogglesDict = getDictFromProfile(profileName: ProfileName.applicationAccess)
        var payloadContentArray = restrictionTogglesDict["PayloadContent"] as? [[String : Any]] ?? []
        var payloadContentDict = payloadContentArray.first ?? [:]
        
        for item in restrictionTogglesArrayFlat {
            for key in item.payloadKeys {
                payloadContentDict[key] = item.payloadValue
            }
        }
        
        payloadContentDict["enforcedSoftwareUpdateDelay"] = softwareUpdateDelayInt
        payloadContentDict["forceDelayedSoftwareUpdates"] = enableDelayedOTA
        
        payloadContentArray[0] = payloadContentDict
        restrictionTogglesDict["PayloadContent"] = payloadContentArray
        
        writeProfileData(profileName: ProfileName.applicationAccess, profileDict: restrictionTogglesDict)
    }
}

#Preview {
    RestrictionTogglesView()
}
