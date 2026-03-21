//
//  FootnoteView.swift
//  Lithium
//
//  Created by lunginspector on 3/7/26.
//

import SwiftUI
import PartyUI

struct FootnoteView: View {
    @State private var returnMessage: String = ""
    @State private var assetTag: String = ""
    @State private var showDebugSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Preview", icon: "eye")) {
                    ZStack {
                        Image("solarium")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 140)
                            .brightness(-0.1)
                        VStack(spacing: 20) {
                            Spacer()
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
                                HStack {
                                    if !returnMessage.isEmpty {
                                        Text(returnMessage)
                                    }
                                    if !assetTag.isEmpty {
                                        Text(assetTag)
                                    }
                                }
                                .font(.system(size: 9))
                                .frame(height: 10)
                                Capsule()
                                    .frame(width: 145, height: 4)
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(.bottom, 10)
                    }
                    .listRowInsets(EdgeInsets())
                }
                Section(header: HeaderLabel(text: "Footnote", icon: "character.cursor.ibeam")) {
                    TextField("Leading Text", text: $returnMessage)
                    TextField("Trailing Text", text: $assetTag)
                }
            }
            .navigationTitle("Lockscreen Footnote")
            .toolbar {
                if weOnADebugBuild {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showDebugSheet.toggle()
                        }) {
                            Image(systemName: "ant")
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button(action: {
                        Haptic.shared.play(.soft)
                        updateFootnotePlist()
                        installProfile(profileName: ProfileName.footnote)
                    }) {
                        ButtonLabel(text: "Install Profile", icon: "party.popper")
                    }
                    .buttonStyle(TranslucentButtonStyle(color: .green))
                }
                .modifier(OverlayBackground(stickBottomPadding: true))
            }
            .sheet(isPresented: $showDebugSheet) {
                ProfileDebugSheet(profileName: ProfileName.footnote)
            }
        }
        .onAppear {
            getFootnoteDataFromPlist()
        }
    }
    func getFootnoteDataFromPlist() {
        let footnoteDict = getPCDictFromProfile(fileName: ProfileName.footnote)
        assetTag = footnoteDict["AssetTagInformation"] as? String ?? ""
        returnMessage = footnoteDict["IfLostReturnToMessage"] as? String ?? ""
    }
    func updateFootnotePlist() {
        var footnoteDict = getDictFromProfile(fileName: ProfileName.footnote)
        var payloadContentArray = footnoteDict["PayloadContent"] as? [[String : Any]] ?? []
        var payloadContentDict = payloadContentArray.first ?? [:]
        
        payloadContentDict["IfLostReturnToMessage"] = returnMessage
        payloadContentDict["AssetTagInformation"] = assetTag
        
        payloadContentArray[0] = payloadContentDict
        footnoteDict["PayloadContent"] = payloadContentArray
        
        writeProfileData(profileName: ProfileName.footnote, profileDict: footnoteDict)
    }
}

// MARK: UI Components
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

#Preview {
    FootnoteView()
}
