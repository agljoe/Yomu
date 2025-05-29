//
//  AccountView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-08.
//

import SwiftUI

struct AccountView: View {
    @State var credentials: Credentials = Credentials()
    @State var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        TextField("Username", text: $credentials.username)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        SecureField("Password", text: $credentials.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        TextField("Client ID", text: $credentials.client_id)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        SecureField("Client Secret", text: $credentials.client_secret)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        Button("Login") {
                            Task {
                                do {
                                    let _ = try await LoginRequest(credentials: credentials).execute()
                                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                } catch let error { print(error.localizedDescription) }
                                credentials.reset()
                            }
                        }
                    }
                    
                    
                    Section {
                        Button("Reauthenticate") {
                            Task {
                                do {
                                    if isLoggedIn {
                                        let _ = try await ReAuthenticationRequest().execute()
                                    }
                                } catch let error { print(error.localizedDescription) }
                            }
                        }
                    }
                    
                    Section {
                        Button("Logout", role: .destructive) {
                            resetCredentials()
                        }
                        
                        Button("Reset", role: .destructive) {
                            resetKeychain()
                        }
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
}

#Preview {
    AccountView()
}
