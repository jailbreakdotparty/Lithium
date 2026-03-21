//
//  ProfileExportSheet.swift
//  Lithium
//
//  Created by lunginspector on 3/17/26.
//

import SwiftUI
import PartyUI

struct ProfileExportSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var profileArray: [ExportableProfileItem] = [
        ExportableProfileItem(icon: "flag", label: "Restriction Toggles", profileName: ProfileName.applicationAccess),
        ExportableProfileItem(icon: "character.cursor.ibeam", label: "Lockscreen Footnote", profileName: ProfileName.sharedDeviceConfiguration),
        ExportableProfileItem(icon: "bell", label: "App Notifications", profileName: ProfileName.notificationSettings)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Profile Options", icon: "gear")) {
                    ForEach(profileArray, id: \.self) { item in
                        Button(action: {
                            exportProfile(profileName: item.profileName)
                        }) {
                            NavigationLabel(text: item.label, icon: item.icon)
                        }
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
