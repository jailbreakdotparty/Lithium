//
//  AppNotificationsView.swift
//  Lithium
//
//  Created by lunginspector on 3/17/26.
//

import SwiftUI
import PartyUI

struct ItemRow: Identifiable, Equatable, Sendable {
    var id: String { label }
    var icon: String
    var label: String
    var minSupportedVersion: Double = 0.0
    var maxSupportedVersion: Double = 99.9
    var tweakArray: [BoolPayloadItem]
}

struct AppNotificationsView: View {
    @State private var appNotificationsArray: [BoolPayloadItem] = []
    @State private var showDebugSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if appNotificationsArray.isEmpty {
                        CompactAlert(label: "No Applications Added!", icon: "questionmark.app.dashed", text: "Click on the plus icon to add an app by bundle identifer. This will disable all notifications for the apps you choose.")
                    } else {
                        CompactAlert(icon: "info.circle", text: "If enabled, the app will no longer be able to send any notifications, including critical and system alerts.")
                    }
                }
                if !appNotificationsArray.isEmpty {
                    Section(header: HeaderLabel(text: "Selected Applications", icon: "checklist")) {
                        ForEach(appNotificationsArray) { app in
                            // i hate swift SO MUCH. this sucks. i had to do this because binding the whole array would cause the app to crash if there was only one item left in the array and it was deleted.
                            PlainToggle(label: app.label, isOn: Binding(
                                get: {
                                    // $0.id - the id of the item it's searching through
                                    // passing false if nothing is found is the main thing fixes the crash, as there's now some kind of value while it's transitioning into an empty array or something.
                                    appNotificationsArray.first(where: { $0.id == app.id })?.payloadValue ?? false
                                },
                                set: { newValue in
                                    // match the index where the searched id to the app id
                                    if let index = appNotificationsArray.firstIndex(where: { $0.id == app.id }) {
                                        // update the index's payloadValue with a new item
                                        appNotificationsArray[index].payloadValue = newValue
                                    }
                                }
                            )
                            )
                            .swipeActions {
                                Button(role: .destructive, action: {
                                    appNotificationsArray.removeAll { $0.id == app.id }
                                }) {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("App Notifications")
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button(action: {
                        Haptic.shared.play(.soft)
                        installProfile(profileName: ProfileName.notificationSettings)
                    }) {
                        ButtonLabel(text: "Install Profile", icon: "party.popper")
                    }
                    .buttonStyle(TranslucentButtonStyle(color: .green))
                }
                .modifier(OverlayBackground(stickBottomPadding: true))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Alertinator.shared.prompt(title: "Add an Application", placeholder: "Insert a Bundle ID (case-sensitive!)") { appBID in
                            guard let appBID else { return }
                            if appBID.isEmpty {
                                Alertinator.shared.alert(title: "Error!", body: "You didn't even add a bundle ID?? 😭")
                            } else if appNotificationsArray.contains(where: { $0.label == appBID }) {
                                Alertinator.shared.alert(title: "Error!", body: "This bundle id has already been added.")
                            } else {
                                appNotificationsArray.append(BoolPayloadItem(label: appBID, payloadKeys: [appBID], payloadValue: true))
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                    .modifier(SolariumButtonTint())
                }
                if weOnADebugBuild {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showDebugSheet = true
                        }) {
                            Image(systemName: "ant")
                        }
                        .modifier(SolariumButtonTint())
                    }
                }
            }
            .sheet(isPresented: $showDebugSheet) {
                ProfileDebugSheet(profileName: ProfileName.notificationSettings)
            }
        }
        .onAppear {
            getAppNotificationsArrayFromPlist()
        }
        .onChange(of: appNotificationsArray) { array in
            updateAppNotificationsPlist()
        }
    }
    /*
     internal plist structure
     
     Dictionary - contains information for the whole plist
     PayloadContent (Array) - contains a dictionary for each custom payload
     Dictionary - contains the payload itself, which includes the keys for the payload as well as NotificationSettings
     NotificationSettings (Array) - contains an array for each set of notification settings
     Dictionary (for appNotificationsArray) - contains the bundle identifier and whether or not notifications are enabled for the app.
     
     i hate this entire structure so much, but i guess it makes sense?
    */
    func getAppNotificationsArrayFromPlist() {
        let plistDict = getDictFromProfile(profileName: ProfileName.notificationSettings)
        let payloadContentArray = plistDict["PayloadContent"] as? [[String : Any]] ?? []
        let payloadContentDict = payloadContentArray.first ?? [:]
        let notificationSettingsArray = payloadContentDict["NotificationSettings"] as? [[String : Any]] ?? []
        
        for application in notificationSettingsArray {
            let appBID = application["BundleIdentifier"] as? String ?? ""
            let isEnabled = application["NotificationsEnabled"] as? Bool ?? false
            appNotificationsArray.append(BoolPayloadItem(label: appBID, payloadKeys: [appBID], payloadValue: isEnabled))
        }
    }
    func updateAppNotificationsPlist() {
        var plistDict = getDictFromProfile(profileName: ProfileName.notificationSettings)
        var payloadContentArray = plistDict["PayloadContent"] as? [[String : Any]] ?? []
        var payloadContentDict = payloadContentArray.first ?? [:]
        var newNotifSettArray: [[String: Any]] = []
        
        for application in appNotificationsArray {
            let appName = application.payloadKeys.first ?? ""
            newNotifSettArray.append(["BundleIdentifier" : appName, "NotificationsEnabled" : application.payloadValue])
        }
        
        payloadContentDict["NotificationSettings"] = newNotifSettArray
        payloadContentArray[0] = payloadContentDict
        plistDict["PayloadContent"] = payloadContentArray
        
        writeProfileData(profileName: ProfileName.notificationSettings, profileDict: plistDict)
    }
}

#Preview {
    AppNotificationsView()
}
