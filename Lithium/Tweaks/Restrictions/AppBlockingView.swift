//
//  AppBlockingView.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import SwiftUI
import PartyUI

struct BIDItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var bundleID: String
}

struct AppBlockingView: View {
    @Binding var rsCurrentDict: NSMutableDictionary
    @AppStorage("BIDArray") private var BIDArray: [BIDItem] = []
    
    @State private var showDebug = false
    
    @State private var newName: String = ""
    @State private var newBID: String = ""
    
    var body: some View {
        List {
            Section {
                TextField("Name", text: $newName)
                TextField("Bundle ID", text: $newBID)
                Button("Add Application") {
                    if newName.isEmpty || newBID.isEmpty || BIDArray.contains(where: { $0.bundleID == newBID }) {
                        Alertinator.shared.alert(title: "That's an invaild application!", body: "Make sure that you've filled out all fields, and try again. Also ensure that you haven't already added this app.")
                    } else {
                        bidCreateKey(item: BIDItem(name: newName, bundleID: newBID))
                    }
                }
            } footer: {
                Text("Bundle IDs are case-sensitive! Toggle an app off to disable it. Unlike the normal \"Hide App\" feature, this'll also remove the app from Settings and the App Library. All app data is preserved.")
            }
            
            Section {
                ForEach(BIDArray) { app in
                    Toggle(isOn: bidKeyBinding(app.bundleID)) {
                        HStack(spacing: 12) {
                            AppIcon(image: bidGetIcon(bid: app.bundleID))
                            VStack(alignment: .leading) {
                                Text(app.name)
                                Text(app.bundleID)
                                    .foregroundStyle(.secondary)
                                    .font(.footnote)
                            }
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            BIDArray.removeAll(where: { $0.id == app.id })
                            removeBid(app.bundleID)
                            Haptic.shared.play(.heavy)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            } header: {
                HeaderLabel(text: "Apps", icon: "square.fill.text.grid.1x2")
            }
        }
        .navigationTitle("App Visibility")
        .safeAreaInset(edge: .bottom) {
            Button {
                Haptic.shared.play(.soft)
                installProfile(profile: Profile.restrictions)
            } label: {
                ButtonLabel(text: "Install Profile", icon: "party.popper")
            }
            .buttonStyle(FancyButtonStyle())
            .modifier(OverlayBackground())
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showDebug.toggle()
                    } label: {
                        Label("Profile Viewer", systemImage: "doc.text")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showDebug) {
            ProfileDebugSheet(item: Profile.restrictions, isPresented: $showDebug)
        }
    }
    
    private func bidCreateKey(item: BIDItem) {
        newName = ""
        newBID = ""
        BIDArray.append(item)
        
        guard let contentArray = rsCurrentDict["PayloadContent"] as? NSArray,
              let plcontent = contentArray.firstObject as? NSDictionary,
              let blockedBIDs = plcontent["blockedAppBundleIDs"] as? NSMutableArray else {
            return
        }
        
        if !blockedBIDs.contains(item.bundleID) {
            blockedBIDs.add(item.bundleID)
        }
        
        writeProfile(rsCurrentDict, profile: Profile.restrictions)
    }
    
    private func removeBid(_ bundleID: String) {
        guard let contentArray = rsCurrentDict["PayloadContent"] as? NSArray,
              let plcontent = contentArray.firstObject as? NSDictionary,
              let blockedBIDs = plcontent["blockedAppBundleIDs"] as? NSMutableArray else {
            return
        }
        
        if blockedBIDs.contains(bundleID) {
            blockedBIDs.remove(bundleID)
        }
        
        writeProfile(rsCurrentDict, profile: Profile.restrictions)
    }
    
    private func bidKeyBinding(_ bundleID: String) -> Binding<Bool> {
        return Binding(get: {
            guard let contentArray = rsCurrentDict["PayloadContent"] as? NSArray,
                  let plcontent = contentArray.firstObject as? NSDictionary,
                  let blockedBIDs = plcontent["blockedAppBundleIDs"] as? NSArray else {
                return true
            }
            
            if blockedBIDs.contains(bundleID) {
                return false
            }
            return true
        }, set: { enabled in
            guard let contentArray = rsCurrentDict["PayloadContent"] as? NSArray,
                  let plcontent = contentArray.firstObject as? NSDictionary,
                  let blockedBIDs = plcontent["blockedAppBundleIDs"] as? NSMutableArray else {
                return
            }
            
            if !enabled {
                if !blockedBIDs.contains(bundleID) {
                    blockedBIDs.add(bundleID)
                }
            } else {
                if blockedBIDs.contains(bundleID) {
                    blockedBIDs.remove(bundleID)
                }
            }
            
            writeProfile(rsCurrentDict, profile: Profile.restrictions)
        })
    }
}

func bidGetIcon(bid: String) -> Image {
    var icon = UIImage()
    icon = ._applicationIconImage(forBundleIdentifier: bid, format: 1, scale: UIScreen.main.scale)
    return Image(uiImage: icon)
}
