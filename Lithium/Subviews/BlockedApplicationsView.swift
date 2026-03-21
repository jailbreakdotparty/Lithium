//
//  BlockedApplicationsView.swift
//  Lithium
//
//  Created by lunginspector on 3/21/26.
//

import SwiftUI
import PartyUI

struct PayloadAppItem: Identifiable, Equatable {
    var id: String { bundleID }
    var bundleID: String
    var isEnabled: Bool = false
}

struct BlockedApplicationsView: View {
    @State private var blockedApplicationsArray: [PayloadAppItem] = []
    @State private var showDebugSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(blockedApplicationsArray) { app in
                    LabeledContent(app.bundleID) {
                        Button(role: .destructive, action: {
                            blockedApplicationsArray.removeAll { $0.id == app.id }
                        }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
            .navigationTitle("Blocked Applications")
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Alertinator.shared.prompt(title: "Add an Application", placeholder: "Insert a Bundle ID (case-sensitive!)") { appBID in
                            guard let appBID else { return }
                            if appBID.isEmpty {
                                Alertinator.shared.alert(title: "Error!", body: "You didn't even add a bundle ID?? 😭")
                            } else if blockedApplicationsArray.contains(where: { $0.bundleID == appBID }) {
                                Alertinator.shared.alert(title: "Error!", body: "This bundle id has already been added.")
                            } else {
                                blockedApplicationsArray.append(PayloadAppItem(bundleID: appBID))
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
                if weOnADebugBuild {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showDebugSheet = true
                        }) {
                            Image(systemName: "ant")
                        }
                    }
                }
            }
            .sheet(isPresented: $showDebugSheet) {
                ProfileDebugSheet(profileName: ProfileName.applicationAccess)
            }
        }
        .onAppear {
            getBlockedApplicationsArrayFromPlist()
        }
        .onChange(of: blockedApplicationsArray) { newValue in
            updateBlockedApplicationsPlist()
        }
    }
    func getBlockedApplicationsArrayFromPlist() {
        let payloadContentDict = getPCDictFromProfile(profileName: ProfileName.applicationAccess)
        let blockedAppBundleIDsArray = payloadContentDict["blockedAppBundleIDs"] as? [String] ?? []
        
        for bundleID in blockedAppBundleIDsArray {
            blockedApplicationsArray.append(PayloadAppItem(bundleID: bundleID))
        }
    }
    func updateBlockedApplicationsPlist() {
        var plistDict = getDictFromProfile(profileName: ProfileName.applicationAccess)
        var payloadContentArray = plistDict["PayloadContent"] as? [[String : Any]] ?? []
        var payloadContentDict = payloadContentArray.first ?? [:]
        var blockedAppBundleIDsArray: [String] = []
        
        for application in blockedApplicationsArray {
            blockedAppBundleIDsArray.append(application.bundleID)
        }
        
        payloadContentDict["blockedAppBundleIDs"] = blockedAppBundleIDsArray
        payloadContentArray[0] = payloadContentDict
        plistDict["PayloadContent"] = payloadContentArray
        
        writeProfileData(profileName: ProfileName.applicationAccess, profileDict: plistDict)
    }
}

#Preview {
    BlockedApplicationsView()
}
