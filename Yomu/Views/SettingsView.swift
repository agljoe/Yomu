//
//  SettingsView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import SwiftUI

struct SettingsView: View {
    @State private var showingLoginAlert = false
    @State var credentials: Credentials
    
    var body: some View {
        Button("Login to MangaDex") {
            showingLoginAlert = true
        }
            .alert("Login", isPresented: $showingLoginAlert) {
                TextField("Username", text: $credentials.username)
                    .autocorrectionDisabled()
                SecureField("Password", text: $credentials.password)
                    .autocorrectionDisabled()
                TextField("Client ID", text: $credentials.client_id)
                    .autocorrectionDisabled()
                SecureField("Secret", text: $credentials.client_secret)
                    .autocorrectionDisabled()
                
                Button("Cancel", role: .cancel) { }
                Button("OK") {
                    Task {
                        try? await auth(for: credentials)
                        credentials.reset()
                    }
                }
            } message: {
                Text("Login to Mangadex")
            }
    }
}


#Preview {
    SettingsView(credentials: Credentials(username: "", password: "", client_id: "", client_secret: ""))
}
