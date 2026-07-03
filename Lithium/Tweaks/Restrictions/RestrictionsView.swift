//
//  RestrictionsView.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import SwiftUI
import PartyUI

struct RestrictionsView: View {
    @State private var rsCurrentDict = NSMutableDictionary()
    @State private var restrictionTweaks: [RestrictionSection] = restrictionsArray
    
    @State private var otaDelayEnabled = false
    @State private var otaDelay = 0
    
    @State private var showDebug = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            Section {
                Toggle("Delay OTA Updates", isOn: $otaDelayEnabled)
                    .onAppear {
                        if let contentArray = rsCurrentDict["PayloadContent"] as? NSArray,
                           let plcontent = contentArray.firstObject as? NSDictionary {
                            otaDelayEnabled = plcontent["forceDelayedSoftwareUpdates"] as? Bool ?? false
                        }
                    }
                    .onChange(of: otaDelayEnabled) { enable in
                        if let contentArray = rsCurrentDict["PayloadContent"] as? NSArray,
                           let plcontent = contentArray.firstObject as? NSMutableDictionary {
                            plcontent["forceDelayedSoftwareUpdates"] = enable
                        }
                        writeProfile(rsCurrentDict, profile: Profile.restrictions)
                    }
                
                if otaDelayEnabled {
                    HStack {
                        Text("Number of Days")
                        Spacer()
                        TextField("90", value: $otaDelay, format: .number)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.trailing)
                            .onAppear {
                                if let contentArray = rsCurrentDict["PayloadContent"] as? NSArray,
                                   let plcontent = contentArray.firstObject as? NSDictionary {
                                    otaDelay = plcontent["enforcedSoftwareUpdateDelay"] as? Int ?? 0
                                }
                            }
                            .onChange(of: otaDelay) { int in
                                var delay = int
                                if delay > 90 {
                                    delay = 90
                                }
                                
                                if let contentArray = rsCurrentDict["PayloadContent"] as? NSArray,
                                   let plcontent = contentArray.firstObject as? NSMutableDictionary {
                                    plcontent["enforcedSoftwareUpdateDelay"] = delay
                                }
                                writeProfile(rsCurrentDict, profile: Profile.restrictions)
                            }
                    }
                }
            } header: {
                HeaderLabel(text: "OTA Updates", icon: "gear")
            } footer: {
                Text("The maximum amount of days that you can delay by are 90 days (or about 3 months). If you are trying to update from a version that's higher than your target, this will **not** work.")
            }
            
            Section {
                NavigationLink("App Visibility", destination: AppBlockingView(rsCurrentDict: $rsCurrentDict))
            }
            
            ForEach($restrictionTweaks) { $section in
                if section.minVrs <= doubleSystemVersion() && section.maxVrs >= doubleSystemVersion() {
                    Section {
                        ForEach($section.items) { $tweak in
                            PlainToggle(
                                text: tweak.name,
                                infoType: tweak.info.type,
                                infoTitle: tweak.info.title,
                                infoMessage: tweak.info.message,
                                isOn: rsKeyBinding(tweak.keys)
                            )
                        }
                    } header: {
                        HeaderLabel(text: section.name, icon: section.icon)
                    }
                }
            }
        }
        .navigationTitle("Restriction Toggles")
        .scrollDismissesKeyboard(.interactively)
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
                    
                    Button(role: .destructive) {
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
            ProfileDebugSheet(item: Profile.restrictions, isPresented: $showDebug)
        }
        .onAppear {
            rsCurrentDict = loadProfile(profile: Profile.restrictions)
        }
    }
    
    private func rsKeyBinding(_ keys: [String]) -> Binding<Bool> {
        return Binding(get: {
            guard let contentArray = rsCurrentDict["PayloadContent"] as? NSArray,
                  let plcontent = contentArray.firstObject as? NSMutableDictionary else {
                return false
            }
            
            if let value = plcontent[keys.first!] as? Bool {
                return value
            }
            return false
        }, set: { enabled in
            guard let contentArray = rsCurrentDict["PayloadContent"] as? NSArray,
                  let plcontent = contentArray.firstObject as? NSMutableDictionary else {
                return
            }
            
            for key in keys {
                plcontent[key] = enabled
            }
            
            writeProfile(rsCurrentDict, profile: Profile.restrictions)
        })
    }
}
