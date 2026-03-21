//
//  ProfileDebugSheet.swift
//  Lithium
//
//  Created by lunginspector on 3/17/26.
//

import SwiftUI
import PartyUI

struct ProfileDebugSheet: View {
    var profileName: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Actions", icon: "wrench.and.screwdriver")) {
                    Button(action: {
                        exportProfile(profileName: profileName)
                    }) {
                        ButtonLabel(text: "Export Profile", icon: "square.and.arrow.up")
                    }
                    .buttonStyle(TranslucentButtonStyle())
                }
                Section(header: HeaderLabel(text: "Profile", icon: "info.circle")) {
                    Text(getTextFromProfile(profileName: profileName))
                        .font(.system(size: 10, design: .monospaced))
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = getTextFromProfile(profileName: profileName)
                            }) {
                                ButtonLabel(text: "Copy Profile", icon: "doc.on.doc")
                            }
                        }
                }
            }
            .navigationTitle("Profile Debugging")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
