//
//  ProfileDataHandlers.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import Foundation
import PartyUI

func loadProfile(profile: Profile) -> NSMutableDictionary {
    do {
        if !fm.fileExists(atPath: profile.savedURL.path) {
            try fm.copyItem(at: profile.templateURL, to: profile.savedURL)
        }
        
        guard let dict = NSMutableDictionary(contentsOf: profile.savedURL) else {
            throw "failed to get a vaild nsmutabledictionary!"
        }
        
        return dict
    } catch {
        print("[!] failed to load profile at path \(profile.savedURL.path): \(error)")
        Alertinator.shared.alert(
            title: "Failed to load saved profile!",
            body: "Tweaks won't apply properly or at all. Please exit the app and try again. Check error logs for more detailed information.",
            actionLabel: "Exit",
            action: {
                exitinator()
            }
        )
    }
    
    return NSMutableDictionary()
}

// i guess it wasn't all that necessary to make this a function now that i think about it, but whatever.
func resetProfile(profile: Profile) {
    do {
        try fm.removeItem(at: profile.savedURL)
        try fm.copyItem(at: profile.templateURL, to: profile.savedURL)
    } catch {
        print("[!] failed to reset profile named \(profile.templateURL.lastPathComponent): \(error)")
        Alertinator.shared.alert(title: "Failed to reset saved profile!", body: "Check error logs for more detailed information.")
    }
}

func writeProfile(_ dict: NSMutableDictionary, profile: Profile) {
    do {
        let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
        try data.write(to: profile.savedURL)
    } catch {
        print("[!] failed to write profile: \(error)")
    }
}
