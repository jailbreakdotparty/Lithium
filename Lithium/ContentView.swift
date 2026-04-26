//
//  ContentView.swift
//  Lithium
//
//  Created by lunginspector on 3/7/26.
//

import SwiftUI
import PartyUI

internal enum SelectableTabs: Int, CaseIterable {
    case home, tweaks
}

struct ContentView: View {
    @State private var selectedTab: SelectableTabs = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(SelectableTabs.home)
            TweaksView()
                .tabItem { Label("Tweaks", systemImage: "wrench.and.screwdriver") }
                .tag(SelectableTabs.tweaks)
        }
        .onChange(of: selectedTab) { newValue in
            Haptic.shared.play(.soft, intensity: 0.6)
        }
    }
}

#Preview {
    ContentView()
}
