//
//  FileManagerHelpers.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import Foundation

enum AppURL {
    static let profiles = URL.documentsDirectory.appendingPathComponent("Profiles")
}

enum Profile {
    case restrictions, notifications, footnote, webclip
    
    var savedURL: URL {
        switch self {
        case .restrictions:
            return AppURL.profiles.appendingPathComponent("com.apple.applicationaccess").appendingPathExtension("mobileconfig")
        case .notifications:
            return AppURL.profiles.appendingPathComponent("com.apple.notificationsettings").appendingPathExtension("mobileconfig")
        case .footnote:
            return AppURL.profiles.appendingPathComponent("com.apple.shareddeviceconfiguration").appendingPathExtension("mobileconfig")
        case .webclip:
            return AppURL.profiles.appendingPathComponent("com.apple.webClip.managed").appendingPathExtension("mobileconfig")
        }
    }
    
    var templateURL: URL {
        switch self {
        case .restrictions:
            return Bundle.main.url(forResource: "com.apple.applicationaccess", withExtension: "mobileconfig")!
        case .notifications:
            return Bundle.main.url(forResource: "com.apple.notificationsettings", withExtension: "mobileconfig")!
        case .footnote:
            return Bundle.main.url(forResource: "com.apple.shareddeviceconfiguration", withExtension: "mobileconfig")!
        case .webclip:
            return Bundle.main.url(forResource: "com.apple.webClip.managed", withExtension: "mobileconfig")!
        }
    }
}

func getFileText(url: URL) -> String {
    do {
        let data = try Data(contentsOf: url)
        
        if let text = String(data: data, encoding: .utf8) {
            return text
        }
        
        return String(decoding: data, as: UTF8.self)
    } catch {
        print("(fm) failed to get text! path: \(error)")
        return ""
    }
}
