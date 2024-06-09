//
//  ContentView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-04.
//

import SwiftUI

struct appState {
    let session: Session
}

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var ID = ""
    @State private var secret = ""
    
    let token: Token
    
    var body: some View {
        VStack {
            Section {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                TextField("Client ID", text: $ID)
                SecureField("Secret", text: $secret)
            }
            .padding(.horizontal)
            
            Button("Test") {
                auth(username: username, password: password, ID: ID, secret: secret)
            }
            
//            Button("ReAuth") {
//                reAuth(token: token.refresh, ID: ID, secret: secret)
//            }
        }
    }
}

#Preview {
    ContentView(token: Token(access_token: "", refresh_token: ""))
}
