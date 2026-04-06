//
//  SettingsView.swift
//  Lithium
//
//  Created by lunginspector on 4/5/26.
//

import SwiftUI
import PartyUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "About", icon: "info.circle")) {
                    VStack(alignment: .leading, spacing: 10) {
                        AppInfoCell()
                        HStack {
                            Button(action: {
                                openURL(URL(string: "https://jailbreak.party/discord")!)
                            }) {
                                ButtonLabel(text: "Discord", icon: "discord", useImage: true)
                            }
                            .buttonStyle(TranslucentButtonStyle(color: .discord))
                            Button(action: {
                                openURL(URL(string: "https://jailbreak.party/discord")!)
                            }) {
                                ButtonLabel(text: "GitHub", icon: "github", useImage: true)
                            }
                            .buttonStyle(TranslucentButtonStyle(color: .github))
                        }
                        Button(action: {
                            openURL(URL(string: "https://jailbreak.party/discord")!)
                        }) {
                            ButtonLabel(text: "Website", icon: "globe")
                        }
                        .buttonStyle(TranslucentButtonStyle())
                    }
                }
                Section(header: HeaderLabel(text: "Credits", icon: "star")) {
                    LinkCreditCell(image: Image("lunginspector"), name: "lunginspector", description: "Primary Developer", url: "https://github.com/lunginspector")
                }
                Section {
                    NavigationLink("Acknowledgements", destination: AcknowledgementsView())
                    NavigationLink("Customize", destination: CustomizeView(colorOptions: [
                        ColorOption(label: "Default", color: Color.accent),
                        ColorOption(label: "Blue", color: Color.blue),
                        ColorOption(label: "Purple", color: Color.purple),
                        ColorOption(label: "Pink", color: Color.pink),
                        ColorOption(label: "Red", color: Color.red),
                        ColorOption(label: "Orange", color: Color.orange),
                        ColorOption(label: "Yellow", color: Color.yellow),
                        ColorOption(label: "Green", color: Color.green)
                    ]))
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                    .modifier(SolariumButtonTint())
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
