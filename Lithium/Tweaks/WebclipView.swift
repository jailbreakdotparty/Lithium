//
//  WebclipView.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import SwiftUI
import PartyUI
import PhotosUI
import UniformTypeIdentifiers

struct WebclipView: View {
    @State private var wcCurrentDict = NSMutableDictionary()
    
    @AppStorage("imageData") private var imageData = Data()
    @AppStorage("label") private var label = ""
    @AppStorage("url") private var url = ""
    @AppStorage("fullScreen") private var fullScreen = true
    @AppStorage("precomposedIcon") private var precomposedIcon = false
    
    @State private var showPhotosPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showFilesPicker = false
    
    @State private var showDebug = false
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .center, spacing: 4) {
                    Menu {
                        Button {
                            showPhotosPicker = true
                        } label: {
                            Label("Choose from Photos", systemImage: "photo")
                        }
                        
                        Button {
                            showFilesPicker = true
                        } label: {
                            Label("Choose from Files", systemImage: "folder")
                        }
                    } label: {
                        Image(uiImage: UIImage(data: imageData) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .background {
                                if imageData.isEmpty {
                                    EmptyIconPlaceholder()
                                }
                            }
                            .modifier(AppIconModifier())
                    }
                    
                    TextField("Label", text: $label)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 13, weight: .medium))
                        .frame(maxWidth: 100)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } header: {
                HeaderLabel(text: "Appearance", icon: "paintbrush")
            }
            .listRowBackground(
                Group {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Image("solarium")
                            .resizable()
                            .scaledToFill()
                            .offset(y: 130)
                    } else {
                        Image("solarium")
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 25)
                    }
                }
            )
            
            Section {
                TextField("Webpage URL", text: $url)
                Toggle("Full Screen", isOn: $fullScreen)
                Toggle("Use Precomposed Icon", isOn: $precomposedIcon)
            } header: {
                HeaderLabel(text: "Properties", icon: "switch.2")
            }
        }
        .navigationTitle("Create Webclip")
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            Button {
                if label.isEmpty || url.isEmpty {
                    Alertinator.shared.alert(title: "That's an invaild webclip!", body: "Make sure that you've filled out all fields properly, and then try again.")
                } else {
                    wcCreateProfile()
                    installProfile(profile: Profile.webclip)
                }
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
                        imageData = Data()
                        label = ""
                        url = ""
                        fullScreen = false
                        precomposedIcon = false
                        Haptic.shared.play(.heavy)
                    } label: {
                        Label("Clear Fields", systemImage: "xmark")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showDebug) {
            ProfileDebugSheet(item: Profile.webclip, isPresented: $showDebug)
        }
        .onChange(of: imageData) { newData in
            imageData = wcCropImage(data: newData)
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { received in
            Task {
                do {
                    guard let newData = try await selectedPhoto?.loadTransferable(type: Data.self) else {
                        throw "failed to get data from image!"
                    }
                    imageData = newData
                } catch {
                    print("(wc) failed to import image: \(error)")
                }
            }
        }
        .fileImporter(isPresented: $showFilesPicker, allowedContentTypes: [.image], onCompletion: { result in
            if case .success(let url) = result {
                // who doesn't love the ios sandbox
                guard url.startAccessingSecurityScopedResource() else {
                    print("(wc) failed to import image: failed to access file")
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                // i've been making a massive mistake and only now have i realized it...
                // if it's marked with try? it's not gonna go into a throw block if something goes wrong cause it's optional, or non-optional, idk the terminology but i'm stupid
                if let newData = try? Data(contentsOf: url) {
                    imageData = newData
                } else {
                    print("(wc) failed to import image: could not read file data")
                }
            }
        })
    }
    
    private func wcCreateProfile() {
        do {
            guard let dict = NSMutableDictionary(contentsOf: Profile.webclip.templateURL) else {
                throw "failed to get template dict!"
            }
            
            dict["PayloadDisplayName"] = "Custom WebClip: \(label)"
            dict["PayloadDescription"] = """
                This profile will add a custom WebClip to your homscreen.
                
                URL: \(url)
                Full Screen: \(fullScreen)
                Use Precomposed Icon: \(precomposedIcon)
                """
            
            guard let contentArray = dict["PayloadContent"] as? NSArray,
                  let plcontent = contentArray.firstObject as? NSMutableDictionary else {
                throw "failed to get PayloadContent!"
            }
            
            plcontent["Label"] = label
            plcontent["URL"] = url
            plcontent["Icon"] = imageData
            plcontent["FullScreen"] = fullScreen
            plcontent["Precomposed"] = precomposedIcon
            
            writeProfile(dict, profile: Profile.webclip)
        } catch {
            print("(wc) failed to generate webclip: \(error)")
        }
    }
    
    // thanks claude
    private func wcCropImage(data: Data) -> Data {
        do {
            guard let image = UIImage(data: data) else {
                throw "failed to get vaild image from data!"
            }
            let target = CGSize(width: 256, height: 256)
            
            // scale the image down
            let wScale = target.width / image.size.width
            let hScale = target.height / image.size.height
            let scale = max(wScale, hScale)
            let scaled = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            
            // center the image
            let x = (target.width - scaled.width) / 2
            let y = (target.height - scaled.height) / 2
            
            // then render it
            let render = UIGraphicsImageRenderer(size: target)
            let cropped = render.image { _ in
                image.draw(in: CGRect(origin: CGPoint(x: x, y: y), size: scaled))
            }
            
            if let newData = cropped.pngData() {
                return newData
            }
            return data
        } catch {
            print("(wc) failed to crop image: \(error)")
        }
        
        return data
    }
}

// MARK: UI Components
struct AppIconModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 19.0, *) {
            content
                .clipShape(.rect(cornerRadius: cornerRad.component))
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRad.component))
        } else {
            content
                .clipShape(.rect(cornerRadius: cornerRad.component))
        }
    }
}

struct EmptyIconPlaceholder: View {
    var body: some View {
        if #available(iOS 19.0, *) {
            Image(systemName: "plus")
                .imageScale(.large)
                .foregroundStyle(Color(.label))
        } else {
            Image(systemName: "plus")
                .imageScale(.large)
                .frame(width: 70, height: 70)
                .background(.quaternary)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRad.component)
                        .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [8]))
                }
                .foregroundStyle(Color(.label))
        }
    }
}

#Preview {
    WebclipView()
}

