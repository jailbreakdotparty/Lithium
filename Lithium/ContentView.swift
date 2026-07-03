//
//  ContentView.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import SwiftUI
import PartyUI

struct ContentView: View {
    let device = UIDevice.current
    @State private var stopAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LogView()
                        .modifier(TerminalPlatter())
                } header: {
                    HeaderLabel(text: "Version \(AppInfo.appVersion) (Release)", icon: "info.circle")
                } footer: {
                    Text("Made with love by the [jailbreak.party](https://jailbreak.party) team.\n[Join the jailbreak.party Discord!](https://jailbreak.party/discord)")
                }
                
                Section {
                    NavigationLink("Restriction Tweaks", destination: RestrictionsView())
                    NavigationLink("Notification Settings", destination: NotificationsView())
                    NavigationLink("Webclips", destination: WebclipView())
                    NavigationLink("Footnote", destination: FootnoteView())
                } header: {
                    HeaderLabel(text: "Tweaks", icon: "wrench.and.screwdriver")
                }
                
                Section {
                    LinkCreditCell(image: Image("lunginspector"), name: "lunginspector", description: "Project creator & maintainer.", url: "https://github.com/lunginspector")
                } header: {
                    HeaderLabel(text: "Credits", icon: "star")
                }
            }
            .navigationTitle("Lithium")
        }
        .onAppear {
            if !stopAlert {
                print("\n[*] Welcome to Lithium! Running on \(device.systemName) \(device.systemVersion), \(machineName()).")
                print("[!] Make sure that your device is supervised before usage! Also, PLEASE don't use this tool if this device is managed by a school or workplace.")
                stopAlert = true
            }
            if !fm.fileExists(atPath: AppURL.profiles.path) {
                try? fm.createDirectory(at: AppURL.profiles, withIntermediateDirectories: false)
                print("[*] created backups directory at \(AppURL.profiles.path)")
            }
        }
    }
}

func machineName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    return machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
}

#Preview {
    ContentView()
}
