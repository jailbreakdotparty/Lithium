//
//  HomeView.swift
//  Lithium
//
//  Created by lunginspector on 3/8/26.
//

import SwiftUI
import PartyUI

struct HomeView: View {
    @State private var showProfileExportingSheet: Bool = false
    @State private var showSettingsView: Bool = false
    
    @AppStorage("enableDebug") var enableDebug: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Logs", icon: "terminal"), footer: Text("Made by lunginspector for the [jailbreak.party](https://jailbreak.party) team.\nJoin the jailbreak.party [discord](https://jailbreak.party/discord)!")) {
                    LogView()
                }
                Section(header: HeaderLabel(text: "Version \(AppInfo.appVersion) (\(AppInfo.appBuild))", icon: "info.circle"), footer: Text("Please make sure that your device is supervised before usage. Otherwise, this tool **will not** function as expected. Made with love by lunginspector for [jailbreak.party](https://jailbreak.party).")) {
                    VStack {
                        Button(action: {
                            showProfileExportingSheet = true
                        }) {
                            ButtonLabel(text: "Export Profiles", icon: "square.and.arrow.up")
                        }
                        .buttonStyle(TranslucentButtonStyle())
                    }
                }
                Section(header: HeaderLabel(text: "Tweaks", icon: "gearshape")) {
                    Toggle("Enable Debug Settings", isOn: $enableDebug)
                }
            }
            .navigationTitle("Lithium")
            .sheet(isPresented: $showProfileExportingSheet) {
                ProfileExportSheet()
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSettingsView.toggle()
                    }) {
                        Image(systemName: "gearshape")
                    }
                    
                }
            }
        }
    }
}

#Preview { HomeView() }
