//
//  GetProfileData.swift
//  Lithium
//
//  Created by lunginspector on 3/20/26.
//

import Foundation

func getDictFromProfile(profileName: String) -> [String : Any] {
    let sourceFileURL = Bundle.main.url(forResource: profileName, withExtension: "mobileconfig")!
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let destinationURL = documentsURL!.appendingPathComponent(profileName).appendingPathExtension("mobileconfig")
    
    if !FileManager.default.fileExists(atPath: destinationURL.path) {
        do {
            try FileManager.default.copyItem(at: sourceFileURL, to: destinationURL)
        } catch {
            print("[!] failed to copy bundle profile template file to documents directory")
        }
    }
    
    if let profileData = try? Data(contentsOf: destinationURL),
       let profileDictionary = try? PropertyListSerialization.propertyList(from: profileData, options: [], format: nil) as? [String : Any] { return profileDictionary }
    
    return [:]
}

func getTextFromProfile(profileName: String) -> String {
    let sourceFileURL = Bundle.main.url(forResource: profileName, withExtension: "mobileconfig")!
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let destinationURL = documentsURL!.appendingPathComponent(profileName).appendingPathExtension("mobileconfig")
    
    if !FileManager.default.fileExists(atPath: destinationURL.path) {
        do {
            try FileManager.default.copyItem(at: sourceFileURL, to: destinationURL)
        } catch { }
    }
    
    do {
        let profileData = try Data(contentsOf: destinationURL)
        let profilePlist = try PropertyListSerialization.propertyList(from: profileData, options: [], format: nil)
        let profileXMLData = try PropertyListSerialization.data(fromPropertyList: profilePlist, format: .xml, options: 0)
        return String(data: profileXMLData, encoding: .utf8) ?? ""
    } catch {
        print("[!] failed to get text contents from profile: \(error)")
        return ""
    }
}

func getPCDictFromProfile(profileName: String) -> [String : Any] {
    let profileDict = getDictFromProfile(profileName: profileName)
    let payloadContentArray = profileDict["PayloadContent"] as? [[String : Any]] ?? []
    return payloadContentArray.first ?? [:]
}
