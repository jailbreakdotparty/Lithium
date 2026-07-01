//
//  TweaksView.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import SwiftUI
import PartyUI

struct TweaksView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Restriction Tweaks", destination: RestrictionsView())
                NavigationLink("Notification Settings", destination: NotificationsView())
            }
            .navigationTitle("Tweaks")
        }
    }
}
