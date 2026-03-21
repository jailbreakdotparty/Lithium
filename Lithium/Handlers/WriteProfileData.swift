//
//  UpdateProfileData.swift
//  Lithium
//
//  Created by lunginspector on 3/7/26.
//

import Foundation

func writeProfileData(profileName: String, profileDict: [String : Any]) {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let destinationURL = documentsURL!.appendingPathComponent(profileName).appendingPathExtension("mobileconfig")
    
    do {
        let encodedPlist = try PropertyListSerialization.data(fromPropertyList: profileDict, format: .xml, options: 0)
        try encodedPlist.write(to: destinationURL)
    } catch {
        print("[!] failed to write updated contents to documents directory!")
    }
}
