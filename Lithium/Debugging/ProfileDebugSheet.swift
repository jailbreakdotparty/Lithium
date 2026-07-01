//
//  ProfileDebugSheet.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import SwiftUI
import PartyUI

struct ProfileDebugSheet: View {
    var item: Profile
    @Binding var isPresented: Bool
    @State private var profileText: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(profileText)
                    .font(.system(size: 10, design: .monospaced))
            }
            .navigationTitle(item.savedURL.lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            UIPasteboard.general.string = profileText
                        } label: {
                            Label("Copy to Clipboard", systemImage: "doc.on.doc")
                        }
                        
                        Button {
                            presentShareSheet(with: item.savedURL)
                        } label: {
                            Label("Export Profile", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(role: .destructive) {
                            resetProfile(profile: item)
                            Haptic.shared.play(.heavy)
                            profileText = getFileText(url: item.savedURL)
                        } label: {
                            Label("Reset Profile", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented.toggle()
                    } label: {
                        CloseSheetLabel()
                    }
                }
            }
            .onAppear {
                profileText = getFileText(url: item.savedURL)
            }
        }
    }
}
