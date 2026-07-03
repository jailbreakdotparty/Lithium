//
//  FootnoteView.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import SwiftUI
import PartyUI

struct FootnoteView: View {
    @State private var ftCurrentDict = NSMutableDictionary()
    
    @AppStorage("leadingText") private var leadingText = ""
    @AppStorage("trailingText") private var trailingText = ""
    
    @State private var showDebug = false
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 14) {
                    HStack {
                        Image(systemName: "flashlight.off.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .padding()
                            .modifier(QuickActionBackground())
                        Spacer()
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .padding()
                            .modifier(QuickActionBackground())
                    }
                    .padding(.horizontal, 35)
                    
                    VStack {
                        HStack(spacing: 4) {
                            if !leadingText.isEmpty {
                                Text(leadingText)
                            }
                            if !trailingText.isEmpty {
                                Text(trailingText)
                            }
                        }
                        .font(.system(size: 9))
                        .frame(height: 10)
                        Capsule()
                            .frame(width: 145, height: 4)
                    }
                }
                .padding(.top, 25)
                .padding(.bottom, 10)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(
                Group {
                    Image("solarium")
                        .resizable()
                        .scaledToFill()
                        .offset(y: 10)
                }
            )
            
            Section {
                HStack {
                    Text("Leading Text")
                    Spacer()
                    TextField("Text", text: $leadingText)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity)
                }
                
                HStack {
                    Text("Trailing Text")
                    Spacer()
                    TextField("Text", text: $trailingText)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity)
                }
            } header: {
                HeaderLabel(text: "Properties", icon: "switch.2")
            }
        }
        .navigationTitle("Footnote")
        .safeAreaInset(edge: .bottom) {
            Button {
                Haptic.shared.play(.soft)
                ftUpdateProfile()
                installProfile(profile: Profile.footnote)
            } label: {
                ButtonLabel(text: "Install Profile", icon: "party.popper")
            }
            .buttonStyle(FancyButtonStyle())
            .modifier(OverlayBackground())
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showDebug.toggle()
                    } label: {
                        Label("Profile Viewer", systemImage: "doc.text")
                    }
                    
                    Button(role: .destructive) {
                        leadingText = ""
                        trailingText = ""
                        resetProfile(profile: Profile.footnote)
                        Haptic.shared.play(.heavy)
                    } label: {
                        Label("Reset Tweak", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showDebug) {
            ProfileViewSheet(item: Profile.footnote, isPresented: $showDebug)
        }
        .onAppear {
            ftCurrentDict = loadProfile(profile: Profile.footnote)
            
            if let contentArray = ftCurrentDict["PayloadContent"] as? NSArray,
               let plcontent = contentArray.firstObject as? NSDictionary,
               let leading = plcontent["IfLostReturnToMessage"] as? String,
               let trailing = plcontent["AssetTagInformation"] as? String {
                if !leading.isEmpty {
                    leadingText = leading
                }
                
                if !trailing.isEmpty {
                    trailingText = trailing
                }
            }
        }
    }
    
    func ftUpdateProfile() {
        do {
            guard let contentArray = ftCurrentDict["PayloadContent"] as? NSArray,
                  let plcontent = contentArray.firstObject as? NSMutableDictionary else {
                throw "failed to get PayloadContent!"
            }
            
            plcontent["IfLostReturnToMessage"] = leadingText
            plcontent["AssetTagInformation"] = trailingText
            
            writeProfile(ftCurrentDict, profile: Profile.footnote)
        } catch {
            print("(ft) failed to update profile: \(error)")
        }
    }
}

// MARK: ui
struct QuickActionBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 19.0, *) {
            content
                .glassEffect(.clear.interactive(), in: .circle)
        } else {
            content
                .background(.ultraThinMaterial, in: .circle)
        }
    }
}
