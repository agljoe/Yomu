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
        username = ""
        password = ""
        client_id = ""
        client_secret = ""
    }
}

public struct Token: Hashable, Codable {
    let access_token: String
    let refresh_token: String?
}

extension Token {
    private enum CodingKeys: String, CodingKey {
        case access_token
        case refresh_token
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

public func auth(for credentials: Credentials) async throws -> Void {
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else { throw AuthenticationError.invalidCredentials }
    
    let value = "application/x-www-form-urlencoded"
    
    guard let content = "grant_type=password&username=\(credentials.username)&password=\(credentials.password)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8) else { throw AuthenticationError.failedToAuthenticate }
    
    do {
        let data = try await Request().post(url: url, value: value, content: content)
        let token = try JSONDecoder().decode(Token.self, from: data)
        try handleToken(username: credentials.username, type: "access", token: token.access_token)
        try handleToken(username: credentials.username, type: "refresh", token: token.refresh_token!)
//        print(token) // implement func handleToken
    } catch { throw AuthenticationError.failedToAuthenticate }
    
}

//TODO: implement OAuth session refresh for reAuthorization

private func reAuth(token: String, credentials: Credentials) async throws -> Void {
    guard let token = try? getToken(type: token) else { throw KeychainError.noToken }
    
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else { throw AuthenticationError.invalidCredentials }
    
    let value = "application/x-www-form-urlencoded"

    guard let content = "grant_type=refresh_token&refresh_token=\(token)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8) else { throw AuthenticationError.invalidCredentials } // key token from keychain
    
    do {
        let data = try await Request().post(url: url, value: value, content: content)
        let token = try JSONDecoder().decode(Token.self, from: data)
        try handleToken(username: credentials.username, type: "access", token: token.access_token) // update token
        try handleToken(username: credentials.username, type: "refresh", token: token.refresh_token!) //update token
    } catch { throw AuthenticationError.failedToAuthenticate }
}

private func handleToken(username: String, type: String, token: String) throws -> Void {
    
    let attribute = type
    
    let account = username
    let token = token.data(using: String.Encoding.utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecAttrLabel as String: type,
        kSecValueData as String: token
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status)}
    print("Success")
    return
}

private func getToken(type: String) throws -> String {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrLabel as String: type,
                                kSecMatchLimit as String: kSecMatchLimitOne,
                                kSecReturnAttributes as String: true,
                                kSecReturnData as String: true]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status != errSecItemNotFound else { throw KeychainError.noPassword }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    
    guard let existingItem = item as? [String : Any],
        let tokenData = existingItem[kSecValueData as String] as? Data,
        let token = String(data: tokenData, encoding: String.Encoding.utf8),
        let type = existingItem[kSecAttrAccount as String] as? String
    else {
        throw KeychainError.unexpectedPasswordData
    }
    
    return token
}

private func updateToken(type: String, credentials: Credentials) throws -> Void {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrLabel as String: type]
    

}
