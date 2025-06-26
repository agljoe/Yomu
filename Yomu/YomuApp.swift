//
//  YomuApp.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-04.
//

import MangaDexData
import SwiftUI

@main
struct YomuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .database(SharedLibraryDatabase.shared.database)
        .modelContainer(SharedLibraryDatabase.shared.modelContainer)
    }
}

