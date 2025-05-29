//
//  YomuApp.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-04.
//

import SwiftData
import SwiftUI

@main
struct YomuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    StoredAuthor.self,
                    StoredChapter.self,
                    StoredCover.self,
                    StoredManga.self,
                    StoredScanlationGroup.self,
                    StoredUser.self
                ])
        }
    }
}

