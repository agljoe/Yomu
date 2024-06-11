//
//  User.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-04.
//

import Foundation

struct User: Identifiable {
    let id: UUID //maybe can be mangadex id
    let username: String
    
}

public enum KeychainError: Error {
    case noPassword
    case noToken
    case unexpectedPasswordData
    case unexpecetedTokenData
    case unhandledError(status: OSStatus)
}

public func addItemoKeychain(sever: String, username: String, password: String, completion: (KeychainError?) -> Void) {
    
    let sever = sever
    
    let account = username
    let password = password.data(using: String.Encoding.utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrAccount as String: account,
        kSecAttrServer as String: sever,
        kSecValueData as String: password
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        completion(KeychainError.unhandledError(status: status))
        return
    }
    
    completion(nil)
}
