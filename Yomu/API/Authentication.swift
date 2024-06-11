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

public enum Session {
    case active
    case expired
}

public func auth(for credentials: Credentials) async throws -> Void {
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL: \(urlString)")
        return
    }
    
    let value = "application/x-www-form-urlencoded"
    
    let content = "grant_type=password&username=\(credentials.username)&password=\(credentials.password)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8)
    
    do {
        let data = try await Request().post(url: url, value: value, content: content)
        let token = try JSONDecoder().decode(Token.self, from: data)
        print(token) // implement func handleToken
    } catch {
        print("Failed to authenticate")
    }
}

//TODO: implement OAuth session refresh for reAuthorization

private func reAuth(for token: Token, credentials: Credentials) async throws -> Void {
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL: \(urlString)")
        return
    }
    
    let value = "application/x-www-form-urlencoded"

    let content = "grant_type=refresh_token&refresh_token=\(token.access_token)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8)
    
    do {
        let data = try await Request().post(url: url, value: value, content: content)
        let token = try JSONDecoder().decode(Token.self, from: data)
        print(token)
    } catch {
        print("Failed to authenticate")
    }
    
}

