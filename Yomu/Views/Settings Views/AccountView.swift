//
//  AccountView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-08.
//

import SwiftUI

struct AccountView: View {
    @State var credentials: Credentials = Credentials()
    
    var body: some View {
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
                }
                
                Button("Login") {
                    Task {
                        do {
                            let _ = try await LoginRequest(credentials: credentials).execute()
                        } catch let error { print(error.localizedDescription) }
                        credentials.reset()
                    }
                }
            }
            
            Form {
                Section {
                    Button("ReAuth") {
                        Task {
                            do {
                                let _ = try await ReAuthenticationRequest().execute()
                            } catch let error { print(error.localizedDescription) }
                        }
                    }
                }
                
                Section {
                    Button("Reset Credentials") {
                        resetCredentials()
                    }
                    
                    Button("Reset KeyChain") {
                        resetKeychain()
                    }
                }
            }
        }
    }
}

#Preview {
    AccountView()
}
