//
//  AccountView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-08.
//

import SwiftUI

struct AccountView: View {
    @State var credentials: Credentials
    
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
                            try await auth(with: credentials)
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
                                try await reAuth()
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
    AccountView(credentials: Credentials(username: "", password: "", client_id: "", client_secret: ""))
}
