//
//  FileManagerHelpers.swift
//  Lithium
//
//  Created by lunginspector on 6/28/26.
//

import Foundation

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
