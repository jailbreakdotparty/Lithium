//
//  ProfileExportSheet.swift
//  Lithium
//
//  Created by lunginspector on 3/17/26.
//

import SwiftUI
import PartyUI

struct ExportableProfileItem: Hashable {
    var id: String { label }
    var label: String
    var profileName: String
}

struct ProfileExportSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var profileArray: [ExportableProfileItem] = [
        ExportableProfileItem(label: "Restriction Toggles/Blocked Applications", profileName: ProfileName.applicationAccess),
        ExportableProfileItem(label: "Lockscreen Footnote", profileName: ProfileName.sharedDeviceConfiguration),
        ExportableProfileItem(label: "App Notifications", profileName: ProfileName.notificationSettings),
        ExportableProfileItem(label: "Webclips", profileName: ProfileName.webclip)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Profile Options", icon: "gear")) {
                    ForEach(profileArray, id: \.self) { item in
                        Button(action: {
                            exportProfile(profileName: item.profileName)
                        }) {
                            NavigationLabel(text: item.label)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Export Profiles")
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
