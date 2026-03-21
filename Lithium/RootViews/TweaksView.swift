//
//  TweaksView.swift
//  Lithium
//
//  Created by lunginspector on 3/8/26.
//

import SwiftUI
import PartyUI

struct TweaksView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle")
                            .imageScale(.large)
                        VStack(alignment: .leading) {
                            Text("Many of these tweaks are grouped by payload. This means that tweaks in the same section will all apply at once.")
                                .font(.callout)
                        }
                    }
                }
                .listRowBackground(Color.blue.opacity(0.2))
                Section(header: HeaderLabel(text: "Restrictions", icon: "checklist")) {
                    NavigationLink("Restriction Toggles", destination: RestrictionTogglesView())
                    NavigationLink("Blocked Applications", destination: BlockedApplicationsView())
                }
                Section(header: HeaderLabel(text: "Other Tweaks", icon: "wrench.and.screwdriver")) {
                    NavigationLink("Lockscreen Footnote", destination: FootnoteView())
                    NavigationLink("App Notifications", destination: AppNotificationsView())
                }
            }
            .navigationTitle("Tweaks")
        }
    }
}

#Preview {
    TweaksView()
}
