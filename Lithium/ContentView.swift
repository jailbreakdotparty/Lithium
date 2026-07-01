//
//  ContentView.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import SwiftUI

enum TabItem {
    case home, tweaks
}

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(TabItem.home)
            
            TweaksView()
                .tabItem {
                    Label("Tweaks", systemImage: "wrench.and.screwdriver")
                }
                .tag(TabItem.tweaks)
        }
        .onAppear {
            if !fm.fileExists(atPath: AppURL.profiles.path) {
                try? fm.createDirectory(at: AppURL.profiles, withIntermediateDirectories: false)
            }
        }
    }
}

#Preview {
    ContentView()
}
