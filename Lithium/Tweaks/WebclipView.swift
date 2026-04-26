//
//  WebclipView.swift
//  Lithium
//
//  Created by lunginspector on 3/24/26.
//

import SwiftUI
import PartyUI
import PhotosUI

struct WebclipView: View {
    @State private var label: String = ""
    @State private var url: String = ""
    
    @State private var useFullScreen: Bool = false
    @State private var usePrecomposedIcon: Bool = false
    
    @State private var icon: Data = Data()
    @State private var selectedPhoto: PhotosPickerItem?
    
    @State private var showDebugSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Preview", icon: "eye"), footer: Text("Click the icon to change it. A perfectly square image is highly recommended.")) {
                    ZStack {
                        Image("solarium")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 140)
                            .brightness(-0.1)
                        VStack {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                if let uiImage = UIImage(data: icon), !icon.isEmpty {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 70, height: 70)
                                        .scaledToFit()
                                        .clipShape(.rect(cornerRadius: cornerRad.component))
                                } else {
                                    EmptyIconPlaceholder()
                                }
                            }
                            .buttonStyle(.plain)
                            Text(label)
                                .font(.system(size: 14))
                                .frame(height: 14)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }
                Section(header: HeaderLabel(text: "Properties", icon: "gearshape")) {
                    TextField("WebClip Label", text: $label)
                    TextField("WebClip URL", text: $url)
                    Toggle("Use Full Screen", isOn: $useFullScreen)
                    Toggle("Use Precomposed Icon", isOn: $usePrecomposedIcon)
                }
            }
            .navigationTitle("WebClip Generator")
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
                        updateWebclipPlist()
                        installProfile(profileName: ProfileName.webclip)
                    }) {
                        ButtonLabel(text: "Install Profile", icon: "party.popper")
                    }
                    .buttonStyle(FancyButtonStyle(color: .green))
                }
                .modifier(OverlayBackground(stickBottomPadding: true))
            }
            .sheet(isPresented: $showDebugSheet) {
                ProfileDebugSheet(profileName: ProfileName.webclip)
            }
        }
        .onAppear {
            getWebclipDataFromPlist()
        }
        // i'd like to thank equatable for deciding that it does not appreicate tuples when they are different types of values.
        .onChange(of: selectedPhoto) { newItem in
            updateIconPreview()
            updateWebclipPlist()
        }
        .onChange(of: label) { newValue in
            updateWebclipPlist()
        }
        .onChange(of: url) { newValue in
            updateWebclipPlist()
        }
        .onChange(of: useFullScreen) { newValue in
            updateWebclipPlist()
        }
        .onChange(of: usePrecomposedIcon) { newValue in
            updateWebclipPlist()
        }
    }
    func getWebclipDataFromPlist() {
        let webclipDict = getPCDictFromProfile(profileName: ProfileName.webclip)
        
        label = webclipDict["Label"] as? String ?? ""
        url = webclipDict["URL"] as? String ?? ""
        useFullScreen = webclipDict["FullScreen"] as? Bool ?? false
        usePrecomposedIcon = webclipDict["Precomposed"] as? Bool ?? false
        icon = webclipDict["Icon"] as? Data ?? Data()
        
        updateIconPreview()
    }
    func updateWebclipPlist() {
        var webclipDict = getDictFromProfile(profileName: ProfileName.webclip)
        var payloadContentArray = webclipDict["PayloadContent"] as? [[String : Any]] ?? []
        var payloadContentDict = payloadContentArray.first ?? [:]
        
        payloadContentDict["Label"] = label
        payloadContentDict["URL"] = url
        payloadContentDict["FullScreen"] = useFullScreen
        payloadContentDict["Precomposed"] = usePrecomposedIcon
        payloadContentDict["Icon"] = icon
        
        payloadContentArray[0] = payloadContentDict
        webclipDict["PayloadContent"] = payloadContentArray
        
        writeProfileData(profileName: ProfileName.webclip, profileDict: webclipDict)
    }
    func updateIconPreview() {
        Task {
            do {
                if let newData = try await selectedPhoto?.loadTransferable(type: Data.self) {
                    icon = newData
                }
            } catch {
                print("[!] failed to update icon preview!")
            }
        }
    }
}

// MARK: UI Components
struct EmptyIconPlaceholder: View {
    var body: some View {
        Image(systemName: "plus")
            .imageScale(.large)
            .frame(width: 70, height: 70)
            .background(.quaternary)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRad.component)
                    .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [8]))
            }
            .clipShape(.rect(cornerRadius: cornerRad.component))
    }
}

#Preview {
    WebclipView()
}
