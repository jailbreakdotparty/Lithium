//
//  ProfileServingServer.swift
//  Lithium
//
//  Created by lunginspector on 3/9/26.
//

// i'd like to make it clear now that i asked ai for this and copied off of it. i really am not too sure what it's doing, or if this will even work properly, so enjoy the #vibecoding.

import Network
import Foundation
import UIKit

// i am the BEST at naming things like this. you can't deny this is fire.
final class ProfileServingServer {
    private var listener: NWListener?
    private let port: NWEndpoint.Port = 51925
    private var profileURL: URL!
    
    func startServingProfile(profileURL: URL) throws {
        self.listener?.cancel()
        self.listener = nil
        self.profileURL = profileURL
        listener = try NWListener(using: .tcp, on: port)
        listener?.newConnectionHandler = { connection in
            connection.start(queue: .main)
            self.handle(connection: connection)
        }
        listener?.start(queue: .main)
    }
    private func handle(connection: NWConnection) {
        // what the hell is the point of doing that???
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { _, _, _, _ in
            guard let profileData = try? Data(contentsOf: self.profileURL) else {
                connection.cancel()
                return
            }
            
            var response = "HTTP/1.1 200 OK\r\n"
            response += "Content-Type: application/x-apple-aspen-config\r\n"
            response += "Content-Length: \(profileData.count)\r\n"
            response += "Content-Disposition: attachment; filename=\"profile.mobileconfig\"\r\n"
            // these two responses block safari from caching it
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
    func knockItOffDude() {
        listener?.cancel()
    }
}
