//
//  NotificationsView.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import SwiftUI
import PartyUI

struct NotificationItem: Identifiable, Codable {
    var id = UUID()
    var name: String = ""
    var bundleID: String
    var isOn = true
}

struct NotificationsView: View {
    @State private var nsCurrentDict = NSMutableDictionary()
    @AppStorage("appArray") private var appArray: [NotificationItem] = []
    
    @State private var newName: String = ""
    @State private var newBID: String = ""
    
    @State private var showDebug = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            Section {
                TextField("Name", text: $newName)
                TextField("Bundle ID", text: $newBID)
                Button("Add Application") {
                    if newName.isEmpty || newBID.isEmpty || appArray.contains(where: { $0.bundleID == newBID }) {
                        Alertinator.shared.alert(title: "That's an invaild application!", body: "Make sure that you've filled out all fields, and try again. Also ensure that you haven't already added this app.")
                    } else {
                        nsCreateKey(item: NotificationItem(name: newName, bundleID: newBID))
                        Haptic.shared.play(.soft)
                    }
                }
            } footer: {
                Text("Bundle IDs are case-sensitive! When an app is toggled off, you will receive no notifications from it whatsoever. This may include critical alerts.")
            }
            
            Section {
                ForEach($appArray) { $app in
                    Toggle(isOn: nsKeyBinding(app.bundleID)) {
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
                            nsRemoveKey(item: app)
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
        .navigationTitle("Notification Settings")
        .safeAreaInset(edge: .bottom) {
            Button {
                installProfile(profile: Profile.notifications)
            } label: {
                ButtonLabel(text: "Install Profile", icon: "party.popper")
            }
            .buttonStyle(FancyButtonStyle())
            .modifier(OverlayBackground(stickBottomPadding: true))
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showDebug.toggle()
                    } label: {
                        Label("Profile Viewer", systemImage: "doc.text")
                    }
                    
                    Button(role: .destructive) {
                        appArray.removeAll()
                        resetProfile(profile: Profile.restrictions)
                        Haptic.shared.play(.heavy)
                        dismiss()
                    } label: {
                        Label("Reset Tweak", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showDebug) {
            ProfileDebugSheet(item: Profile.notifications, isPresented: $showDebug)
        }
        .onAppear {
            nsLoadData()
        }
    }
    
    private func nsLoadData() {
        do {
            nsCurrentDict = loadProfile(profile: Profile.notifications)
            
            guard let contentArray = nsCurrentDict["PayloadContent"] as? NSArray,
                  let plcontent = contentArray.firstObject as? NSDictionary,
                  let apps = plcontent["NotificationSettings"] as? NSArray else {
                throw "failed to get NotificationSettings!"
            }
            
            for app in apps {
                guard let dict = app as? NSDictionary,
                      let bundleID = dict["BundleIdentifier"] as? String,
                      let isOn = dict["NotificationsEnabled"] as? Bool else {
                    throw "dict for notification setting is malformed!"
                }
                
                if let index = appArray.firstIndex(where: { $0.bundleID == bundleID }) {
                    appArray[index].bundleID = bundleID
                    appArray[index].isOn = isOn
                } else {
                    appArray.append(NotificationItem(name: "Unknown App", bundleID: bundleID, isOn: isOn))
                }
            }
        } catch {
            print("(ns) failed to load data: \(error)")
        }
    }
    
    private func nsCreateKey(item: NotificationItem) {
        do {
            appArray.append(item)
            
            guard let contentArray = nsCurrentDict["PayloadContent"] as? NSArray,
                  let plcontent = contentArray.firstObject as? NSDictionary,
                  let apps = plcontent["NotificationSettings"] as? NSMutableArray else {
                throw "failed to get NotificationSettings!"
            }
            
            let newItem: [String: Any] = [
                "BundleIdentifier": item.bundleID,
                "NotificationsEnabled": item.isOn
            ]
            
            apps.add(newItem)
            
            writeProfile(nsCurrentDict, profile: Profile.notifications)
        } catch {
            print("(ns) failed to create key: \(error)")
        }
    }
    
    private func nsRemoveKey(item: NotificationItem) {
        do {
            appArray.removeAll(where: { $0.id == item.id })
            
            guard let contentArray = nsCurrentDict["PayloadContent"] as? NSArray,
                  let plcontent = contentArray.firstObject as? NSDictionary,
                  let apps = plcontent["NotificationSettings"] as? NSMutableArray else {
                throw "failed to get NotificationSettings!"
            }
            
            for app in apps {
                guard let dict = app as? NSMutableDictionary,
                      let storedBID = dict["BundleIdentifier"] as? String else {
                    throw "dict for notification setting is malformed!"
                }
                
                if storedBID == item.bundleID {
                    apps.remove(app)
                }
            }
            
            writeProfile(nsCurrentDict, profile: Profile.notifications)
        } catch {
            print("(ns) failed to remove key: \(error)")
        }
    }
    
    private func nsKeyBinding(_ bundleID: String) -> Binding<Bool> {
        return Binding(get: {
            if let index = appArray.firstIndex(where: { $0.bundleID == bundleID }) {
                return appArray[index].isOn
            }
            return true
        }, set: { value in
            if let index = appArray.firstIndex(where: { $0.bundleID == bundleID }) {
                appArray[index].isOn = value
            }
            
            guard let contentArray = nsCurrentDict["PayloadContent"] as? NSArray,
                  let plcontent = contentArray.firstObject as? NSDictionary,
                  let apps = plcontent["NotificationSettings"] as? NSArray else {
                print("(ns) failed to get NotificationSettings!")
                return
            }
            
            for app in apps {
                guard let dict = app as? NSMutableDictionary,
                      let storedBID = dict["BundleIdentifier"] as? String else {
                    print("(ns) dict for notification setting is malformed!")
                    return
                }
                
                if storedBID == bundleID {
                    print("match found, updating with value \(value)...")
                    dict["NotificationsEnabled"] = value
                }
            }
            
            writeProfile(nsCurrentDict, profile: Profile.notifications)
        })
    }
}
