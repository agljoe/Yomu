//
//  AccountView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-08.
//

import SwiftUI

struct AccountView: View {
    @Environment(\.database) var database
    @State private var model: Model = Model()
    
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
                                try? await model.login()
                                model.credentials.reset()
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
                            resetCredentials()
                            /// delete all swift data modles
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

extension AccountView {
    @Observable
    class Model {
        var credentials: Credentials = Credentials()
        var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
        var isLoading: Bool = false
        
        @MainActor
        func setup() async throws {
            guard !isLoading && isLoggedIn else { return }
            let _ = try await AccountView.Model.getLibrary()
            
        }
        
        @MainActor
        func login() async throws {
            guard !isLoggedIn else { return }
            defer { UserDefaults.standard.set(true, forKey: "isLoggedIn") }
            let _ = try await LoginRequest(credentials: credentials).execute()
        }
        
        @MainActor
        func reauthenticate() async throws {
            guard !isLoggedIn else { return }
            defer { UserDefaults.standard.set(true, forKey: "isLoggedIn") }
            let _ = try await ReAuthenticationRequest().execute()
        }
        
        nonisolated static private func getLibrary() async throws -> [String: [UUID]] {
            async let statuses = AllMangaReadingStatusRequest().execute()
            let mapped: [(UUID, String)] = try await statuses.map { (UUID(uuidString: $0.0)!, $0.1) }
            let grouped = Dictionary(grouping: mapped, by: { $0.1 })
            var result = [String: [UUID]]()
            for (key, value) in grouped { result[key] = value.map(\.0) }
            return result
        }
    }
}

#Preview {
    AccountView()
}
