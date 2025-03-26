//
//  AuthenticatedRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-24.
//

import Foundation

/// A collection of identifiers used to get OAuth tokens for a  user
///
/// A `Credentials` value encapsulates all user information required to login using the MangaDexApi.
///
/// The MangaDexApi requies users to login in order to create the associated OAuth access and refresh tokens.
///
/// For more information see [Personal Clients](https://api.mangadex.org/docs/02-authentication/personal-clients/).
struct Credentials: Codable, Hashable, Sendable {
    let username: String
    let password: String
    let client_id: String
    let client_secret: String
    
    /// Creates a ``Credentials`` instance initialized with placeholder values.
    init() {
        self.username = ""
        self.password = ""
        self.client_id = ""
        self.client_secret = ""
    }
    
    /// Creates a ``Credentials`` instance by the given values.
    init(username: String, password: String, client_id: String, client_secret: String) {
        self.username = username
        self.password = password
        self.client_id = client_id
        self.client_secret = client_secret
    }
}


/// A value passed in the `authorization` header of a HTTP request for authenticated OAuth calls.
///
///  MangaDex specifies that ``Token/access`` is  used for all endpoints requiring authorization headers, except when generating new access tokens.
///
///    For more information on authentication using the MangaDexApi see [Personal Clients](https://api.mangadex.org/docs/02-authentication/personal-clients/).
struct Token: Codable, Hashable {
    let access: String
    let refresh: String?
    
    /// Creates a Token value with access initalized as an empty string.
    init() {
        self.access = ""
        self.refresh = nil
    }
    
    /// Create a Token value given a specified access.
    init(access: String, refresh: String?) {
        self.access = access
        self.refresh = refresh
    }
    
    /// Keys used to decode JSON data returned from MangaDex servers.
    private enum CodingKeys: String, CodingKey {
        case access = "access_token"
        case refresh = "refresh_token"
    }
    
    /// Creates new instance by decoding from any decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.access = try container.decode(String.self, forKey: .access)
        self.refresh = try container.decodeIfPresent(String.self, forKey: .refresh)
    }
}

/// An error that occurs when making authenticated requests.
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
            return String(localized: "Failed to login, context")
        }
    }
}

/// An error that occurs when storing, or retriving values from a KeyChain.
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
private func storeToken(_ token: String, for username: String, ofType type: String) throws {
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

extension MangaDexAPIEntity {
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
    public func authenticatedGet(from url: URL) async throws -> Data {
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
    public func authenticatedPost(at url: URL, for value: String? = nil, with content: Data? = nil) async throws {
        guard let token = try? getToken(ofType: "access") else { throw KeychainError.noToken }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(value ?? "application/json", forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = true
        request.timeoutInterval = 90
        
        if let body = content { request.httpBody = body }
        
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
    public func authenticatedDelete(at url: URL) async throws {
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
}



