//
//  YomuApp.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-04.
//

import DataThespian
import MangaDexData
import SwiftData
import SwiftUI

@main
struct YomuApp: App {
//    private static let databaseChangePublicist = DatabaseChangePublicist()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .database(SharedLibraryDatabase.shared.database)
        .modelContainer(SharedLibraryDatabase.shared.modelContainer)
//        .environment(\.databaseChangePublicist, YomuApp.databaseChangePublicist)
    }
    
//    internal init() {
//        DataMonitor.shared.begin(with: [])
//    }
}

