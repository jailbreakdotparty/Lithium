//
//  HomeView.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import SwiftUI
import PartyUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LogView()
                        .modifier(TerminalPlatter())
                } header: {
                    HeaderLabel(text: "Logs", icon: "terminal")
                }
            }
            .navigationTitle("Lithium")
        }
    }
}
