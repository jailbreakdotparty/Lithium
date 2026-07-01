//
//  ProfileInstallHandlers.swift
//  Lithium
//
//  Created by lunginspector on 6/30/26.
//

import SwiftUI
import UIKit
import Network
import SafariServices

func installProfile(profile: Profile) {
    print("[*] attempting to serve profile for file at \(profile.savedURL.path)")
    try? ProfileInstallServer().startServingProfile(fileURL: profile.savedURL)
    
    let safariView = SafariWebView(url: URL(string: "http://127.0.0.1:51925/")!)
    UIApplication.shared.windows.first?.rootViewController?.present(UIHostingController(rootView: safariView), animated: true, completion: nil)
}

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}

final class ProfileInstallServer {
    private var listener: NWListener?
    private let port: NWEndpoint.Port = 51925
    private var fileURL: URL!
    
    func startServingProfile(fileURL: URL) throws {
        self.listener?.cancel()
        self.listener = nil
        self.fileURL = fileURL
        listener = try NWListener(using: .tcp, on: port)
        listener?.newConnectionHandler = { connection in
            connection.start(queue: .main)
            self.handle(connection: connection)
        }
        listener?.start(queue: .main)
    }
    
    private func handle(connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { _, _, _, _ in
            guard let profileData = try? Data(contentsOf: self.fileURL) else {
                connection.cancel()
                return
            }
            
            var response = "HTTP/1.1 200 OK\r\n"
            response += "Content-Type: application/x-apple-aspen-config\r\n"
            response += "Content-Length: \(profileData.count)\r\n"
            response += "Content-Disposition: attachment; filename=\"profile.mobileconfig\"\r\n"
            response += "Pragma: no-cache\r\n"
            response += "Expires: 0\r\n"
            response += "\r\n"
            
            var responseData = Data(response.utf8)
            responseData.append(profileData)
            
            connection.send(content: responseData, completion: .contentProcessed { _ in
                connection.cancel()
                self.listener?.cancel()
                self.listener = nil
            })
        }
    }
}
