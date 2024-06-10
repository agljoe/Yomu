//
//  Authentication.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation

public struct Credentials: Codable {
    var username: String
    var password: String
    var client_id: String
    var client_secret: String
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

//enum KeychainError: Error {
//    case noPassword
//    case unexpectedPasswordData
//    case unhandledError(status: OSStatus)
//}
//
//let credentials = Credentials(username: "A", password: "A", client_id: "A", client_secret: "A")
//
//let sever = "https://auth.mangadex.org"
//
//let account = credentials.username
//let password = credentials.password.data(using: String.Encoding.utf8)!
//var query: [String: Any] = [
//    kSecClass as String: kSecClassInternetPassword,
//    kSecAttrAccount as String: account,
//    kSecAttrServer as String: sever,
//    kSecValueData as String: password
//]
//
//let status = SecItemAdd(query as CFDictionary, nil)
//guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }


public func login(username: String, password: String, ID: String, secret: String, completion: @escaping (Bool) -> Void) {
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL: \(urlString)")
        completion(false)
        return
    }
    
    let value = "application/x-www-form-urlencoded"
    
    let credentials = "grant_type=password&username=\(username)&password=\(password)&client_id=\(ID)&client_secret=\(secret)".data(using: .utf8)
    
    Request().post(url: url, value: value, content: credentials, result: Token.self) { response, error  in
        switch response {
        case .none:
            print("No response recived from server")
            completion(false)
            return
        case .some(_):
            if response?.statusCode == 200 {
                print("OK")
                completion(true)
            } else {
                completion(false)
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

