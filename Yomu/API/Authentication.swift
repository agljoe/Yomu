//
//  Authentication.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation

public struct Credentials: Codable, Sendable {
    var username: String
    var password: String
    var client_id: String
    var client_secret: String
    
    mutating func reset() {
        password = ""
        client_secret = ""
    }
}

public struct Token: Hashable, Codable {
    let access: String
    let refresh: String?
}

extension Token {
    private enum CodingKeys: String, CodingKey {
        case access = "access_token"
        case refresh = "refresh_token"
    }
}

public enum AuthenticationError: Error {
    case invalidCredentials
    case failedToAuthenticate
}

public enum KeychainError: Error {
    case noPassword
    case noToken
    case unexpectedPasswordData
    case unexpecetedTokenData
    case unhandledError(status: OSStatus)
}

public func auth(for credentials: Credentials) async throws -> () {
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else { throw AuthenticationError.invalidCredentials }
    
    let value = "application/x-www-form-urlencoded"
    
    guard let content = "grant_type=password&username=\(credentials.username)&password=\(credentials.password)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8) else { throw AuthenticationError.failedToAuthenticate }
    
    do {
        let data = try await Request().post(url: url, value: value, content: content)
        let token = try JSONDecoder().decode(Token.self, from: data)
        try handleToken(username: credentials.username, type: "access", token: token.access)
        try handleToken(username: credentials.username, type: "refresh", token: token.refresh!)
    } catch { throw AuthenticationError.failedToAuthenticate }
    
    try storeCredentials(username: credentials.username, password: credentials.password, server: "https://mangadex.org")
    try storeCredentials(username: credentials.client_id, password: credentials.client_secret, server: "https://auth.mangadex.org")
    
}

//TODO: implement OAuth session refresh for reAuthorization

private func reAuth() async throws -> () {
    guard let token = try? getToken(type: "refresh") else { throw KeychainError.noToken }
    guard let credentials = try? getCredentials(server: "https://auth.mangadex.org") else { throw KeychainError.noPassword }
    
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else { throw AuthenticationError.invalidCredentials }
    
    let value = "application/x-www-form-urlencoded"

    guard let content = "grant_type=refresh_token&refresh_token=\(token)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8) else { throw AuthenticationError.invalidCredentials }
    
    do {
        let data = try await Request().post(url: url, value: value, content: content)
        let token = try JSONDecoder().decode(Token.self, from: data)
        try handleToken(username: credentials.username, type: "access", token: token.access)
    } catch { throw AuthenticationError.failedToAuthenticate }
}

public func storeCredentials(username: String, password: String, server: String) throws -> () {
    let server = server

    let account = username
    let password = password.data(using: String.Encoding.utf8)!
    
    let query: [String: Any] = [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrAccount as String: account,
        kSecAttrServer as String: server,
        kSecValueData as String: password
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
}

private func getCredentials(server: String) throws -> Credentials {
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

private func handleToken(username: String, type: String, token: String) throws -> () {
    
    let attribute = type
    
    let account = username
    let token = token.data(using: String.Encoding.utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecAttrLabel as String: attribute,
        kSecValueData as String: token
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status)}
}

public func getToken(type: String) throws -> String {
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

private func updateToken(username: String, type: String, token: String) throws -> () {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrLabel as String: type]
    
    let account = username
    let type = type
    let token = token.data(using: String.Encoding.utf8)!
    let attributes: [String: Any] = [
        kSecAttrPath as String: account,
        kSecAttrLabel as String: type,
        kSecValueData as String: token
    ]
    
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    guard status != errSecItemNotFound else { throw KeychainError.noToken }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    
    try deleteKeyChainItem(query: query)

}

private func deleteKeyChainItem(query: [String: Any]) throws -> () {
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
}
