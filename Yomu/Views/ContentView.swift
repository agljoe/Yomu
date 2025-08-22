//
//  ContentView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-04.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            TabView {
                Tab("Updates", systemImage: "doc.text.image") {
                    UpdatesView()
                }
                
                Tab("Library", systemImage: "books.vertical") {
                    LibraryView()
                }
                
                Tab("Community", systemImage: "person.2") {
                    CommunityView()
                }
                
                Tab("Search", systemImage: "magnifyingglass") {
                    SearchView()
                }
                
                Tab("Settings", systemImage: "gear") {
                    SettingsView()
                }
            }
        } else {
            TabView {
                Tab("Updates", systemImage: "doc.text.image") {
                    UpdatesView()
                }
                
                Tab("Library", systemImage: "books.vertical") {
                    LibraryView()
                }
                
                Tab("Community", systemImage: "person.2") {
                    CommunityView()
                }
                
                Tab("Search", systemImage: "magnifyingglass") {
                    SearchView()
                }
                
                Tab("Settings", systemImage: "gear") {
                    SettingsView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
