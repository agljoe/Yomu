//
//  Authentication.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation

struct Credentials: Codable {
    var username: String
    var password: String
    var client_id: String
    var client_secret: String
    
    mutating func reset() {
        password = ""
        client_secret = ""
    }
}

private struct Token: Hashable, Codable {
    let access: String
    let refresh: String?
    
    private enum CodingKeys: String, CodingKey {
        case access = "access_token"
        case refresh = "refresh_token"
    }
}

public enum AuthenticationError: Error {
    case invalidCredentials
    case failedToAuthenticate
}

extension AuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return String(localized: "Invalid credentials")
        case .failedToAuthenticate:
            return String(localized: "Failed to login")
        }
    }
}

public enum KeychainError: Error {
    case noPassword
    case noToken
    case unexpectedPasswordData
    case unexpecetedTokenData
    case unhandledError(status: OSStatus)
}

extension KeychainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noPassword:
            return String(localized: "No password found for user.")
        case .noToken:
            return String(localized: "No token found for user.")
        case .unexpectedPasswordData:
            return String(localized: "Unexpected or incorrectly formatted password data found.")
        case .unexpecetedTokenData:
            return String(localized: "Unexpected or incorrectly formatted token data found.")
        case .unhandledError(status: let status):
            return String(localized: "Uhandled error thrown: \(SecCopyErrorMessageString(status, nil)!)")
        }
    }
}

func auth(for credentials: Credentials) async throws {
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else { throw AuthenticationError.invalidCredentials }
    
    let value = "application/x-www-form-urlencoded"
    
    guard let content = "grant_type=password&username=\(credentials.username)&password=\(credentials.password)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8) else { throw AuthenticationError.failedToAuthenticate }
    
    do {
        let data = try await post(url: url, value: value, content: content)
        let token = try JSONDecoder().decode(Token.self, from: data)
        #if DEBUG
        print(token)
        #endif
        
        try handleToken(username: credentials.username, type: "access", token: token.access)
        try handleToken(username: credentials.username, type: "refresh", token: token.refresh!)

    } catch let error {
        #if DEBUG
        print("Failed to store token(s) in keychain")
        #endif
        throw error
    }
    
    do {
        try storeCredentials(username: credentials.username, password: credentials.password, server: "https://mangadex.org")
        try storeCredentials(username: credentials.client_id, password: credentials.client_secret, server: "https://auth.mangadex.org")
    } catch let error {
        #if DEBUG
        print("Failed to store credentials in keychain")
        print(error.localizedDescription)
        #endif
    }
    
}

func reAuth() async throws {
    guard let token = try? getToken(type: "refresh") else { throw KeychainError.noToken }
    guard let credentials = try? getCredentials(for: "https://auth.mangadex.org") else { throw KeychainError.noPassword }
    
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else { throw AuthenticationError.invalidCredentials }
    
    let value = "application/x-www-form-urlencoded"
    
    guard let content = "grant_type=refresh_token&refresh_token=\(token)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8) else { throw AuthenticationError.invalidCredentials }
    
    do {
        let data = try await post(url: url, value: value, content: content)
        let token = try JSONDecoder().decode(Token.self, from: data)
        #if DEBUG
        print(token)
        #endif
        try updateToken(username: credentials.username, type: "access", token: token.access)
    } catch { throw AuthenticationError.failedToAuthenticate }
    
}

private func storeCredentials(username: String, password: String, server: String) throws {
    let password = password.data(using: String.Encoding.utf8)!
    
    let query: [String: Any] = [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrAccount as String: username,
        kSecAttrServer as String: server,
        kSecValueData as String: password
    ]
    
    let status = SecItemCopyMatching(query as CFDictionary, nil)
    if (status == errSecItemNotFound) {
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
}

private func getCredentials(for server: String) throws -> Credentials {
    let query: [String: Any] = [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrServer as String: server,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnAttributes as String: true,
        kSecReturnData as String: true
    ]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status != errSecItemNotFound else { throw KeychainError.noPassword }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    
    guard let existingItem = item as? [String : Any],
          let passwordData = existingItem[kSecValueData as String] as? Data,
          let password = String(data: passwordData, encoding: String.Encoding.utf8),
          let account = existingItem[kSecAttrAccount as String] as? String
    else { throw KeychainError.unexpectedPasswordData }
    
    if server == "https://mangadex.org" {
        return Credentials(username: account, password: password, client_id: "", client_secret: "")
    } else if server == "https://auth.mangadex.org" {
        return Credentials(username: "", password: "", client_id: account, client_secret: password)
    } else { throw KeychainError.noPassword }
}

private func handleToken(username: String, type: String, token: String) throws {
    let tokenData = token.data(using: String.Encoding.utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "\(username)/\(type)",
        kSecAttrLabel as String: type,
        kSecValueData as String: tokenData
    ]
    
    let status = SecItemCopyMatching(query as CFDictionary, nil)
    if (status == errSecItemNotFound) {
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    } else {
        try updateToken(username: username, type: type, token: token)
    }
}

private func getToken(type: String) throws -> String {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrLabel as String: type,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnAttributes as String: true,
        kSecReturnData as String: true
    ]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status != errSecItemNotFound else { throw KeychainError.noPassword }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    
    guard let existingItem = item as? [String : Any],
          let tokenData = existingItem[kSecValueData as String] as? Data,
          let token = String(data: tokenData, encoding: String.Encoding.utf8),
          let _ = existingItem[kSecAttrLabel as String] as? String
    else { throw KeychainError.unexpectedPasswordData }
    
    return token
}

private func updateToken(username: String, type: String, token: String) throws {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrLabel as String: type
    ]
    
    let token = token.data(using: String.Encoding.utf8)!
    let attributes: [String: Any] = [
        kSecAttrAccount as String: "\(username)/\(type)",
        kSecAttrLabel as String: type,
        kSecValueData as String: token
    ]
    
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    guard status != errSecItemNotFound else { throw KeychainError.noToken }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
}

private func deleteKeyChainItem(query: [String: Any]) throws {
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
}

func resetCredentials() {
    do {
        let credentials = try getCredentials(for: "https://mangadex.org")
        
        let access: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "\(credentials.username)/access",
            kSecAttrLabel as String: "access",
        ]
        
        try deleteKeyChainItem(query: access)
    } catch let error { print("Error deleting access token from keychain: \(error.localizedDescription)") }
    
    do {
        let credentials = try getCredentials(for: "https://mangadex.org")
        
        let refresh: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "c\(credentials.username)/refresh",
            kSecAttrLabel as String: "refresh",
        ]
        
        try deleteKeyChainItem(query: refresh)
    } catch let error { print("Error deleting refresh token from keychain: \(error.localizedDescription)") }
    
    
    do {
        let credentials = try getCredentials(for: "https://mangadex.org")
        
        let user: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrPath as String: credentials.username,
            kSecAttrServer as String: "https://mangadex.org",
        ]
        
        try deleteKeyChainItem(query: user)
    } catch let error { print("Error deleting user from keychain: \(error.localizedDescription)") }
    
    do {
        let credentials = try getCredentials(for: "https://auth.mangadex.org")
        
        let client: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrPath as String: credentials.client_id,
            kSecAttrServer as String: "https://auth.mangadex.org",
        ]
        
        try deleteKeyChainItem(query: client)
    } catch let error { print("Error deleting client from keychain: \(error.localizedDescription)") }
}

// Requests w/ authentication headers
func authGet(for url: URL) async throws -> Data {
    guard let token = try? getToken(type: "access") else { throw KeychainError.noToken }
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpShouldHandleCookies = true
    request.timeoutInterval = 90
    
    request.httpMethod = "GET"
    
    var (data, response) = try await URLSession.shared.data(for: request)
    
    if (response as? HTTPURLResponse)?.statusCode == 401 {
        do {
            try await reAuth()
            guard let token = try? getToken(type: "access") else { throw KeychainError.noToken }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            (data, response) = try await URLSession.shared.data(for: request)
        } catch KeychainError.noToken {
            // promt user to login
        } catch KeychainError.noPassword {
            // promt user to login
        } catch AuthenticationError.invalidCredentials {
            // unable to login / not logged in alert
        } catch {
            throw AuthenticationError.failedToAuthenticate
        }
    }
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw httpError(for: (response as! HTTPURLResponse)) }
    return data
}

func authPost(url: URL, value: String?, content: Data?) async throws {
    guard let token = try? getToken(type: "access") else { throw KeychainError.noToken }
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue(value ?? "application/json", forHTTPHeaderField: "Content-Type")
    request.httpShouldHandleCookies = true
    request.timeoutInterval = 90
    
    if (content != nil) { request.httpBody = content }
    
    request.httpMethod = "POST"
    
    var (_, response) = try await URLSession.shared.data(for: request)
    
    if (response as? HTTPURLResponse)?.statusCode == 401 {
        do {
            try await reAuth()
            guard let token = try? getToken(type: "access") else { throw KeychainError.noToken }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            (_, response) = try await URLSession.shared.data(for: request)
        } catch KeychainError.noToken {
            // promt user to login or try auth with credentials
        } catch KeychainError.noPassword {
            // promt user to login
        } catch AuthenticationError.invalidCredentials {
            // unable to login alert
        } catch {
            throw AuthenticationError.failedToAuthenticate
        }
    }
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw httpError(for: (response as! HTTPURLResponse)) }
}

func authDelete(for url: URL) async throws {
    guard let token = try? getToken(type: "access") else { throw KeychainError.noToken }
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpShouldHandleCookies = true
    request.timeoutInterval = 90
    
    request.httpMethod = "DELETE"
    
    var (_, response) = try await URLSession.shared.data(for: request)
    
    if (response as? HTTPURLResponse)?.statusCode == 401 {
        do {
            try await reAuth()
            guard let token = try? getToken(type: "access") else { throw KeychainError.noToken }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            (_, response) = try await URLSession.shared.data(for: request)
        } catch KeychainError.noToken {
            // promt user to login or try auth with credentials
        } catch KeychainError.noPassword {
            // promt user to login
        } catch AuthenticationError.invalidCredentials {
            // unable to login alert
        } catch {
            throw AuthenticationError.failedToAuthenticate
        }
    }
}


