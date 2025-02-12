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
                UpdatesView()
                    .tabItem {
                        Label("Updates", systemImage: "doc.text.image")
                    }
                
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "books.vertical")
                    }
                
                CommunityView()
                    .tabItem {
                        Label("Community", systemImage: "person.2")
                    }
                
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        } else {
            NavigationStack {
                TabView {
                    UpdatesView()
                        .tabItem {
                            Label("Updates", systemImage: "doc.text.image")
                        }
                    
                    LibraryView()
                        .tabItem {
                            Label("Library", systemImage: "books.vertical")
                        }
                    
                    CommunityView()
                        .tabItem {
                            Label("Community", systemImage: "person.2")
                        }
                    
                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
