//
//  SettingsView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import SwiftUI

struct SettingsView: View {
    @State private var showingLoginAlert = false
    @State private var query = ""
    @State var credentials: Credentials
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            Form {
                Section {
                    Text("Account")
                }
                
                Section {
                    NavigationLink {
                        GeneralView()
                    } label: {
                        HStack {
                            Icon(symbol: "gear", symbolSize: .large, symbolColor: .white, iconColor: .gray)
                            Text("General")
                        }
                    }
                    
                    NavigationLink {
                        AppearanceView()
                    } label: {
                        HStack {
                            Icon(symbol: "photo", symbolSize: .medium, symbolColor: .white, iconColor: .teal)
                            Text("Appearance")
                        }
                    }
                    
                    Section {
                        NavigationLink {
                            AccessibilityView()
                        } label: {
                            HStack {
                                Icon(symbol: "accessibility", symbolSize: .large, symbolColor: .white, iconColor: .blue)
                                Text("Accessibility")
                            }
                        }
                    }
                }
                
                Section {
                    NavigationLink {
                        SearchSettingsView()
                    } label: {
                        HStack {
                            Icon(symbol: "magnifyingglass", symbolSize: .medium, symbolColor: .white, iconColor: .green)
                            Text("Search")
                        }
                    }
                }
                        
                Section {
                    NavigationLink {
                        ReaderSettingsView()
                    } label : {
                        HStack {
                            Icon(symbol: "book.fill", symbolSize: .medium, symbolColor: .white, iconColor: .orange)
                            Text("Reader")
                        }
                    }
                    
                    NavigationLink {
                        LibrarySettingsView()
                    } label: {
                        HStack {
                            Icon(symbol: "books.vertical.fill", symbolSize: .medium, symbolColor: .white, iconColor: .purple)
                            Text("Library")
                        }
                    }
                }
                
                Section {
                    Link("Support Mangadex", destination: URL(string: "https://namicomi.com/en/org/3Hb7HnWG/mangadex/subscriptions?utm_source=md&utm_campaign=support-us")!)
                }
            }
            .toolbar(removing: .sidebarToggle)
            .navigationTitle("Settings")
            .searchable(text: $query)
        } detail: {
            GeneralView()
        }
        .navigationSplitViewStyle(.balanced)
    }
//            .alert("Login", isPresented: $showingLoginAlert) {
//                TextField("Username", text: $credentials.username)
//                    .autocorrectionDisabled()
//                SecureField("Password", text: $credentials.password)
//                    .autocorrectionDisabled()
//                TextField("Client ID", text: $credentials.client_id)
//                    .autocorrectionDisabled()
//                SecureField("Secret", text: $credentials.client_secret)
//                    .autocorrectionDisabled()
//                
//                Button("Cancel", role: .cancel) { }
//                Button("OK") {
//                    Task {
//                        try? await auth(for: credentials)
//                        credentials.reset()
//                    }
//                }
//            } message: {
//                Text("Login to Mangadex")
//            }
//    }
}


#Preview {
    SettingsView(credentials: Credentials(username: "", password: "", client_id: "", client_secret: ""))
}
