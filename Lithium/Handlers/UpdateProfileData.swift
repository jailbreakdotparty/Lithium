//
//  UpdateProfileData.swift
//  Lithium
//
//  Created by lunginspector on 3/7/26.
//

import Foundation

// my dumbass idea actually worked, lmfao.
// i'm only doing it this way because i honestly do not feel like creating one struct that handles these items, the value not being directly inferred loves to just break everything.
func updateProfilePlist(name: String, stringData: [StringPayloadItem] = [], boolData: [BoolPayloadItem] = []) {
    var profileDict = getDictionaryFromProfile(name)
    var payloadContentDict = profileDict["PayloadContent"] as? [[String : Any]] ?? []
    
    for item in boolData {
        for payloadKey in item.payloadKeys {
            payloadContentDict[0][payloadKey] = item.payloadValue
        }
    }
    for item in stringData {
        payloadContentDict[0][item.payloadKey] = item.payloadValue
    }
    
    profileDict["PayloadContent"] = payloadContentDict
    
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    let destinationURL = documentsURL!.appendingPathComponent(name).appendingPathExtension("mobileconfig")
    do {
        let encodedPlist = try PropertyListSerialization.data(fromPropertyList: profileDict, format: .xml, options: 0)
        try encodedPlist.write(to: destinationURL)
    } catch {
        print("[!] failed to write updated contents to documents directory!")
    }
}
