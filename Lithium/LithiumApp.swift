//
//  LithiumApp.swift
//  Lithium
//
//  Created by lunginspector on 3/7/26.
//

import SwiftUI
import PartyUI

var weOnADebugBuild: Bool = false
var pipe = Pipe()
var sema = DispatchSemaphore(value: 0)

@main
struct LithiumApp: App {
    @AppStorage("enableDebug") var enableDebug: Bool = false
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = false
    
    init() {
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        
        #if DEBUG
        weOnADebugBuild = true
        if !isFirstLaunch {
            enableDebug = true
            isFirstLaunch = true
        }
        #else
        weOnADebugBuild = false
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if weOnADebugBuild {
                        print("[*] it's debugging time!!! Running \(AppInfo.appName) on version \(AppInfo.appVersion), build \(AppInfo.appBuild).")
                    } else {
                        print("[*] Welcome to Lithium! Make sure that you supervise your device before usage. Running \(AppInfo.appName) on version \(AppInfo.appVersion), build \(AppInfo.appBuild).")
                    }
                }
        }
    }
}

// allow arrays to be stored into AppStorage
extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

extension String: @retroactive Error {}
