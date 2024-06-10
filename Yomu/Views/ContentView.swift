//
//  ContentView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-04.
//

import SwiftUI

struct ContentView: View {
    @State public var showingLoginAlert = false
    @State var credentials: Credentials
    
    var body: some View {
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
        .alert("Login", isPresented: $showingLoginAlert) {
            TextField("Username", text: $credentials.username)
                .autocorrectionDisabled()
            SecureField("Password", text: $credentials.password)
                .autocorrectionDisabled()
            SecureField("Client ID", text: $credentials.client_id)
                .autocorrectionDisabled()
            SecureField("Secret", text: $credentials.client_secret)
                .autocorrectionDisabled()
            
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                login(username: credentials.username, password: credentials.password, ID: credentials.client_id, secret: credentials.client_secret) { succeded in
                    if succeded {
                        showingLoginAlert = false
                    }
                }
                      }
        } message: {
            Text("Please login to Mangadex")
        }
    }
}

#Preview {
    ContentView(credentials: Credentials(username: "", password: "", client_id: "", client_secret: ""))
}
