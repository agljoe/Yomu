//
//  Authentication.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation
/// Login with provided credentials.
///
///  >Note: Credentials are provided in the format `application/x-www-form-urlencoded` not `JSON`.
///
/// - Parameter credentials: the  username, password, client id, and client secret for a user.
///
/// - Throws: `MDApiError.invalidURL` if a URL cannot be constructed from urlString.
/// - Throws: `AuthenticationError.invalidCredentials` if provided credentials cannot be encoded.
func auth(with credentials: Credentials) async throws {
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else { throw MDApiError.invalidURL(context: "could not create URL at \(urlString)") }
    
    let value = "application/x-www-form-urlencoded"
    
    guard let content = "grant_type=password&username=\(credentials.username)&password=\(credentials.password)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8) else { throw AuthenticationError.invalidCredentials }
    
    do {
        let data = try await post(at: url, value: value, content: content)
        let token = try JSONDecoder().decode(Token.self, from: data)
        try storeToken(credentials.username, token.access, ofType: "access")
        if let refresh = token.refresh { try storeToken(credentials.username, refresh, ofType: "refresh") }
    } catch let decodingError as DecodingError {
        handleDecodingError(decodingError)
    } catch let keychainError { print(keychainError.localizedDescription) }
    
    do {
        try storeCredentials(credentials.username, credentials.password, for: "https://mangadex.org")
        try storeCredentials(credentials.client_id, credentials.client_secret, for: "https://auth.mangadex.org")
    } catch let keychainError {
        print("Failed to store credentials in keychain")
        print(keychainError.localizedDescription)
    }
}

/// Generates a new access token using the refresh token.
///
/// >Note: Credentials are provided in the format `application/x-www-form-urlencoded` not `JSON`.
///
/// - Throws: `KeychainError.noToken` if a refresh token cannot be found.
/// - Throws: `KeyChainError.noPassword` if credentials cannot be found.
func reAuth() async throws {
    guard let token = try? getToken(ofType: "refresh") else { throw KeychainError.noToken }
    guard let credentials = try? getCredentials(for: "https://auth.mangadex.org") else { throw KeychainError.noPassword }
    
    let urlString = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token"
    
    guard let url = URL(string: urlString) else { throw MDApiError.invalidURL(context: "could not create URL at \(urlString)") }
    
    let value = "application/x-www-form-urlencoded"
    
    guard let content = "grant_type=refresh_token&refresh_token=\(token)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8) else { throw AuthenticationError.invalidCredentials }
    
    do {
        let data = try await post(at: url, value: value, content: content)
        let token = try JSONDecoder().decode(Token.self, from: data)
        try updateToken(for: credentials.username, ofType: "access", token.access)
        #if DEBUG
        print(token)
        #endif
    } catch let decodingError as DecodingError {
        handleDecodingError(decodingError)
    } catch let KeyChainError {
        print(KeyChainError.localizedDescription)
    }
}

/// Stores a user's credentials in the Keychain.
///
/// - Parameters:
///     - username: the  username of a user .
///     - password: the password of a user.
///     - server: a server for credentials to be stored.
///
/// - Throws: `KeyhchainError.unhandleError` if storing credentials fails.
private func storeCredentials(_ username: String, _ password: String, for server: String) throws {
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

/// Retrives a user's credentials from the Keychain.
///
/// - Parameter server: a server for the credentials to be retrived.
///
/// - Throws: `KeyhchainError.noPassword` if no associated password is found.
/// - Throws: `KeyhchainError.unhandledError` if retrival fails.
/// - Throws: `KeyhchainError.unexpectedPasswordData` if returned password is not associated with the specified server.
///
/// - Returns: A ``Credentials`` value associated with the specified server.
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

/// Stores a token associated with an account, and its type.
///
/// - Parameters:
///     - username: the user associated with a token.
///     - type: the type for a given token.
///     - token: the value of an OAuth token.
///
/// - Throws:- Throws: `KeyhchainError.unhandleError` if storing a token fails.
private func storeToken(_ username: String, _ token: String, ofType type: String) throws {
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
        try updateToken(for: username, ofType: type, token)
    }
}

/// Retrives a type of token associated with an account.
///
/// - Parameters:
///     - type: the type for a given token.
///
/// - Throws: `KeyhchainError.noToken` if no associated token is found.
/// - Throws: `KeyhchainError.unhandledError` if retrival fails.
/// - Throws: `KeyhchainError.unexpectedPasswordData` if returned token is not the correct type.
///
/// - Returns: A unencoded token string.
private func getToken(ofType type: String) throws -> String {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrLabel as String: type,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnAttributes as String: true,
        kSecReturnData as String: true
    ]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status != errSecItemNotFound else { throw KeychainError.noToken }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    
    guard let existingItem = item as? [String : Any],
          let tokenData = existingItem[kSecValueData as String] as? Data,
          let token = String(data: tokenData, encoding: String.Encoding.utf8),
          let _ = existingItem[kSecAttrLabel as String] as? String
    else { throw KeychainError.unexpectedPasswordData }
    
    return token
}

/// Updates the value of a token in Keychain.
///
/// - Parameters:
///     - username: the user associated with a token.
///     - type: the type for a given token.
///     - token: the value of an OAuth token.
///
/// - Throws: `KeyhchainError.noToken` if no associated token is found.
/// - Throws: `KeyhchainError.unhandledError` if updating fails.
private func updateToken(for username: String, ofType type: String, _ token: String) throws {
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

/// Removes an item from the Keychain.
///
/// - Parameter query: a Keychain query for a specified item.
///
/// - Throws: `KeychainError.unhandledError`if the item at the query does not exist.
private func deleteKeyChainItem(_ query: [String: Any]) throws {
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
}

/// Removes a users credentials from the Keychain.
public func resetCredentials() {
    do {
        let credentials = try getCredentials(for: "https://mangadex.org")
        
        let access: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "\(credentials.username)/access",
            kSecAttrLabel as String: "access",
        ]
        
        try deleteKeyChainItem(access)
    } catch let error { print("Error deleting access token from keychain: \(error.localizedDescription)") }
    
    do {
        let credentials = try getCredentials(for: "https://mangadex.org")
        
        let refresh: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "\(credentials.username)/refresh",
            kSecAttrLabel as String: "refresh",
        ]
        
        try deleteKeyChainItem(refresh)
    } catch let error { print("Error deleting refresh token from keychain: \(error.localizedDescription)") }
    
    
    do {
        let credentials = try getCredentials(for: "https://mangadex.org")
        
        let user: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrPath as String: credentials.username,
            kSecAttrServer as String: "https://mangadex.org",
        ]
        
        try deleteKeyChainItem(user)
    } catch let error { print("Error deleting user from keychain: \(error.localizedDescription)") }
    
    do {
        let credentials = try getCredentials(for: "https://auth.mangadex.org")
        
        let client: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrPath as String: credentials.client_id,
            kSecAttrServer as String: "https://auth.mangadex.org",
        ]
        
        try deleteKeyChainItem(client)
    } catch let error { print("Error deleting client from keychain: \(error.localizedDescription)") }
}

/// Removes all items from the Keychain.
/// >Warning: This action cannot be undone.
public func resetKeychain() {
    [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity].forEach {
        let status = SecItemDelete([
            kSecClass: $0,
            kSecAttrSynchronizable: kSecAttrSynchronizableAny
        ] as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Error deleting user from keychain")
        }
    }
}

/// Performs an OAuth authenticated HTTP GET request from a server for the given `url`.
///
/// OAuth authenticated Api calls requires using the authentication header which is normally a reserved by URLSession, however Apple has stated that setting this header is the
/// only way to make OAuth requests.
///
/// - Parameter url: the url for a specific sever.
///
/// - Throws: `KeychainError.noToken` if an access token cannot be found.
/// - Throws: ``httpError(_:context:)``  if returned status code is not 200.
///
/// - Returns: a data value from the specified server.
public func authGet(from url: URL) async throws -> Data {
    guard let token = try? getToken(ofType: "access") else { throw KeychainError.noToken }
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "accept")
    request.httpShouldHandleCookies = true
    request.timeoutInterval = 90
    
    request.httpMethod = "GET"
    
    var (data, response) = try await URLSession.shared.data(for: request)
    
    if (response as? HTTPURLResponse)?.statusCode == 401 {
        do {
            try await reAuth()
            guard let token = try? getToken(ofType: "access") else { throw KeychainError.noToken }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            (data, response) = try await URLSession.shared.data(for: request)
        }  catch let keychainError as KeychainError {
            // promt user to login
            print(keychainError.localizedDescription)
        } catch AuthenticationError.invalidCredentials {
            // unable to login alert
        } catch { throw AuthenticationError.failedToAuthenticate }
    }
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw httpError((response as! HTTPURLResponse), context: "\(String(data: data, encoding: .utf8) ?? "no context available").")
    }
    
    return data
}

/// Performs an OAuth authenticated HTTP POST  request from a server for the given `url`.
///
/// OAuth authenticated Api calls requires using the authentication header which is normally a reserved by URLSession, however Apple has stated that setting this header is the
/// only way to make OAuth requests.
///
/// - Parameters:
///     - url: the url for a specific sever.
///     - value: a string specifying the value for the `Content-Type` header field.
///     - content: an encoded data value passed to a specific server as the request's body.
/// > Important: The caller is responsible for encoding the data in the correct format, ensure that the data you are passing is correctly configured for the specified server.
///
/// > Note: Unlike ``post(at:value:content:)``, ``authPost(at:for:with:)`` defaults to using `application/json` for `Content-Type`
///
/// - Throws: `KeychainError.noToken` if an access token cannot be found.
/// - Throws: ``httpError(_:context:)``  if returned status code is not 200.
public func authPost(at url: URL, for value: String? = nil, with content: Data? = nil) async throws {
    guard let token = try? getToken(ofType: "access") else { throw KeychainError.noToken }
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue(value ?? "application/json", forHTTPHeaderField: "Content-Type")
    request.httpShouldHandleCookies = true
    request.timeoutInterval = 90
    
    if (content != nil) { request.httpBody = content }
    
    request.httpMethod = "POST"
    
    var (data, response) = try await URLSession.shared.data(for: request)
    
    if (response as? HTTPURLResponse)?.statusCode == 401 {
        do {
            try await reAuth()
            guard let token = try? getToken(ofType: "access") else { throw KeychainError.noToken }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let keychainError as KeychainError {
            // promt user to login
            print(keychainError.localizedDescription)
        } catch AuthenticationError.invalidCredentials {
            // unable to login alert
        } catch { throw AuthenticationError.failedToAuthenticate }
    }
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw httpError((response as! HTTPURLResponse), context: "\(String(data: data, encoding: .utf8) ?? "no context available").")
    }
}

/// Performs an OAuth authenticated HTTP DELETE  at a server for the given `url`.
///
/// OAuth authenticated Api calls requires using the authentication header which is normally a reserved by URLSession, however Apple has stated that setting this header is the
/// only way to make OAuth requests.
///
/// - Parameters:
///     - url: the url for a specifc sever.
///
/// >Warning: This may irreversibly delete data on a live server, ensure you know the endpoint requirements.
///
/// - Throws: `KeychainError.noToken` if an access token cannot be found.
/// - Throws: ``httpError(_:context:)``  if returned status code is not 200.
public func authDelete(at url: URL) async throws {
    guard let token = try? getToken(ofType: "access") else { throw KeychainError.noToken }
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpShouldHandleCookies = true
    request.timeoutInterval = 90
    
    request.httpMethod = "DELETE"
    
    var (data, response) = try await URLSession.shared.data(for: request)
    
    if (response as? HTTPURLResponse)?.statusCode == 401 {
        do {
            try await reAuth()
            guard let token = try? getToken(ofType: "access") else { throw KeychainError.noToken }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let keychainError as KeychainError {
            // promt user to login
            print(keychainError.localizedDescription)
        } catch AuthenticationError.invalidCredentials {
            // unable to login alert
        } catch { throw AuthenticationError.failedToAuthenticate }
    }
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw httpError((response as! HTTPURLResponse), context: "\(String(data: data, encoding: .utf8) ?? "no context available").")
    }
}
