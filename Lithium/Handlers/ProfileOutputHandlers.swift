//
//  ProfileOutputHandlers.swift
//  Lithium
//
//  Created by lunginspector on 3/7/26.
//

import Foundation
import PartyUI
import UIKit

func exportProfile(name: String) {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let fileURL = documentsURL!.appendingPathComponent(name).appendingPathExtension("mobileconfig")
    PartyUI.presentShareSheet(with: fileURL)
}

func installProfile(profileName: String) {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsURL.appendingPathComponent(profileName).appendingPathExtension("mobileconfig")
    
    try? ProfileServingServer().startServingProfile(profileURL: fileURL)
    
    if let url = URL(string: "http://127.0.0.1:51925/") {
        UIApplication.shared.open(url)
    }
}
