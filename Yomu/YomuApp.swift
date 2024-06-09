//
//  YomuApp.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-04.
//

import SwiftUI

@main
struct YomuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(token: Token(access_token: "", refresh_token: ""))
        }
    }
}
