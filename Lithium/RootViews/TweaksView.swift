//
//  TweaksView.swift
//  Lithium
//
//  Created by lunginspector on 3/8/26.
//

import SwiftUI

struct TweaksView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Restriction Toggles", destination: RestrictionTogglesView())
                NavigationLink("Lockscreen Footnote", destination: FootnoteView())
                NavigationLink("App Notifications", destination: AppNotificationsView())
            }
            .navigationTitle("Tweaks")
        }
    }
}
