//
//  AccountView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-08.
//

import MangaDexData
import MangaDexAPIKit
import SwiftUI

struct AccountView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("loggedInUser") var loggedInUser: String = ""
    @Environment(\.database) var database
    @State private var model = AccountViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        TextField("Username", text: $model.credentials.username)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        SecureField("Password", text: $model.credentials.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        TextField("Client ID", text: $model.credentials.client_id)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        SecureField("Client Secret", text: $model.credentials.client_secret)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        Button("Login") {
                            Task {
                                do {
                                    try await model.login()
                                    loggedInUser = model.credentials.username
                                    isLoggedIn = true
                                    model.credentials.reset()
                                } catch let error {
                                    print(error)
                                }
                            }
                        }
                        
                        Button("Import Library") {
                            Task {
                                try await model.setup()
                            }
                        }
                    }
                    
                    Section {
                        Button("Reauthenticate") {
                            Task { try? await model.reauthenticate() }
                        }
                    }
                    
                    Section {
                        Button("Logout", role: .destructive) {
                            do {
                                try KeychainManager.remove(credentials: loggedInUser)
                                isLoggedIn = false
                                SharedLibraryDatabase.shared.modelContainer.deleteAllData()
                            } catch let error {
                                print(error)
                            }
                        }
                        
                        Button("Reset", role: .destructive) {
                            KeychainManager.reset()
                            isLoggedIn = false
                            loggedInUser = ""
                            SharedLibraryDatabase.shared.modelContainer.deleteAllData()
                        }
                    }
                }
            }
            .navigationTitle("Account")
        }
        .overlay( Group { if model.isLoading { ProgressView() } } )
    }
}

#Preview {
    AccountView()
}
