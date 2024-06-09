//
//  Authentication.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation

public struct Credentials: Hashable, Codable {
    let grant_type: String
    let username: String
    let password: String
    let client_id: String
    let client_secret: String
}

public struct Token: Hashable, Codable {
    let access_token: String
    let refresh_token: String
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
    
func auth(username: String, password: String, ID: String, secret: String) {
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL: \(urlString)")
        return
    }
    
    let value = "application/x-www-form-urlencoded"
    
    let credentials = "grant_type=password&username=\(username)&password=\(password)&client_id=\(ID)&client_secret=\(secret)".data(using: .utf8)
    
    Request().post(url: url, value: value, content: credentials, result: Token.self) { response, error  in
        switch response {
        case .none:
            print("No response recived from server")
        case .some(_):
            if response?.statusCode == 200 {
               
            }
        }
    }
}

//TODO: implement OAuth session refresh for reAuthorization

private func reAuth(token: String, ID: String, secret: String) {
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL: \(urlString)")
        return
    }
    
    let value = "application/x-www-form-urlencoded"

    let credentials = "grant_type=refresh_token&refresh_token=\(token)&client_id=\(ID)&client_secret=\(secret)".data(using: .utf8)
    
    Request().post(url: url, value: value, content: credentials, result: Token.self) { response, error in
        print(response ?? "No response from server.")
    }
    
}

