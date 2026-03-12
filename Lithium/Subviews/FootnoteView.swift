//
//  FootnoteView.swift
//  Lithium
//
//  Created by lunginspector on 3/7/26.
//

import SwiftUI
import PartyUI

struct FootnoteView: View {
    @AppStorage("returnMessage") private var returnMessage: String = ""
    @AppStorage("assetTag") private var assetTag: String = ""
    @State private var isExportDisabled: Bool = true
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Footnote", icon: "character.cursor.ibeam")) {
                    TextField("Leading Text", text: $returnMessage)
                    TextField("Trailing Text", text: $assetTag)
                }
            }
            .navigationTitle("Lockscreen Footnote")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Haptic.shared.play(.soft)
                        updateProfilePlist(name: ProfileName.footnote, stringData: [StringPayloadItem(payloadKey: "AssetTagInformation", payloadValue: assetTag), StringPayloadItem(payloadKey: "IfLostReturnToMessage", payloadValue: returnMessage)])
                        isExportDisabled = false
                    }) {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button(action: {
                        Haptic.shared.play(.soft)
                        installProfile(profileName: ProfileName.footnote)
                    }) {
                        ButtonLabel(text: "Install Profile", icon: "party.popper")
                    }
                    .buttonStyle(TranslucentButtonStyle(color: .green))
                    .disabled(isExportDisabled)
                }
                .modifier(OverlayBackground(stickBottomPadding: true))
            }
        }
        .onChange(of: returnMessage) { newValue in
            isExportDisabled = true
        }
        .onChange(of: assetTag) { newValue in
            isExportDisabled = true
        }
    }
}
