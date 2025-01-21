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
                            try await auth(for: credentials)
                        } catch let error { print(error.localizedDescription) }
                        credentials.reset()
                    }
                }
            }
            .padding()
        }
        
        Button("ReAuth") {
            Task {
                do {
                    try await reAuth()
                } catch let error { print(error.localizedDescription) }
            }
        }

        
        Button("Reset Credentials") {
            resetCredentials()
        }

    }
}

#Preview {
    AccountView(credentials: Credentials(username: "", password: "", client_id: "", client_secret: ""))
}
