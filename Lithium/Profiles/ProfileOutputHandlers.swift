//
//  ProfileOutputHandlers.swift
//  Lithium
//
//  Created by lunginspector on 3/7/26.
//

import Foundation
import PartyUI
import UIKit
import SwiftUI
import SafariServices

func exportProfile(profileName: String) {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let fileURL = documentsURL!.appendingPathComponent(profileName).appendingPathExtension("mobileconfig")
    print("[*] attempting to show share sheet for file at \(String(fileURL.path()))")
    PartyUI.presentShareSheet(with: fileURL)
}

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}

func installProfile(profileName: String) {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsURL.appendingPathComponent(profileName).appendingPathExtension("mobileconfig")
    
    print("[*] attempting to serve profile for file at \(String(fileURL.path()))")
    try? ProfileServingServer().startServingProfile(profileURL: fileURL)
    
    let safariView = SafariWebView(url: URL(string: "http://127.0.0.1:51925/")!)
    UIApplication.shared.windows.first?.rootViewController?.present(UIHostingController(rootView: safariView), animated: true, completion: nil)
}
