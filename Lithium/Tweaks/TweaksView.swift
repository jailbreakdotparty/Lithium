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
                    PlainAlert(icon: "info.circle", text: "Any of the tweaks grouped by payload will apply all at once.")
                }
                .foregroundStyle(Color.accentColor)
                .listRowBackground(Color.accentColor.opacity(0.2))
                Section(header: HeaderLabel(text: "Restrictions", icon: "checklist")) {
                    NavigationLink("Restriction Toggles", destination: RestrictionTogglesView())
                    NavigationLink("Blocked Applications", destination: BlockedApplicationsView())
                }
                Section(header: HeaderLabel(text: "Other Tweaks", icon: "wrench.and.screwdriver")) {
                    NavigationLink("Lockscreen Footnote", destination: FootnoteView())
                    NavigationLink("Disable App Notifications", destination: AppNotificationsView())
                    NavigationLink("Webclip Generator", destination: WebclipView())
                }
            }
            .navigationTitle("Tweaks")
        }
    }
}

#Preview {
    TweaksView()
}
