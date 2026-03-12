//
//  HomeView.swift
//  Lithium
//
//  Created by lunginspector on 3/8/26.
//

import SwiftUI
import PartyUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Version \(AppInfo.appVersion) (\(AppInfo.appBuild))", icon: "info.circle"), footer: Text("Please make sure that your device is supervised before usage. Otherwise, this tool **will not** function as expected. Made with love by lunginspector for [jailbreak.party](https://jailbreak.party).")) {
                    Text("lithium app edition real?!")
                    Text("leak = [removal from the tester program]")
                }
            }
            .navigationTitle("Lithium")
        }
    }
}

#Preview { HomeView() }
