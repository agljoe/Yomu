//
//  LoginRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-26.
//

import Foundation


import Foundation

/// A collection of identifiers used to get OAuth tokens for a  user
///
/// A `Credentials` value encapsulates all user information required to login using the MangaDexApi.
///
/// The MangaDexApi requies users to login in order to create the associated OAuth access and refresh tokens.
///
/// For more information see [Personal Clients](https://api.mangadex.org/docs/02-authentication/personal-clients/).
struct Credentials: Codable, Hashable, Sendable {
    var username: String
    var password: String
    var client_id: String
    var client_secret: String
    
    /// Creates a ``Credentials`` instance initialized with placeholder values.
    ///
    /// - Returns: A Credentials value containing only empty string.
    init() {
        self.username = ""
        self.password = ""
        self.client_id = ""
        self.client_secret = ""
    }
    
    /// Creates a ``Credentials`` instance initalized to the given values.
    ///
    /// - Parameters:
    ///     - username: a username.
    ///     - password: a password.
    ///     - client_id: an identifier for a MangaDexAPI client.
    ///     - client_secret: a key used to authenticate a MangaDexAPI client.
    ///
    ///  - Returns: a newly created Credentials value initialized with the given values.
    init(username: String, password: String, client_id: String, client_secret: String) {
        self.username = username
        self.password = password
        self.client_id = client_id
        self.client_secret = client_secret
    }
    
    /// Sets the value of all members to empty strings.
    mutating func reset() {
        self.username = ""
        self.password = ""
        self.client_id = ""
        self.client_secret = ""
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
    ///
    /// - Returns: a Token with no access or refresh token.
    init() {
        self.access = ""
        self.refresh = nil
    }
    
    /// Create a Token value given a specified access.
    ///
    /// - Parameters:
    ///     - access: a token value that is used for OAuth authenticated API calls.
    ///     - refresh: a token value that is used to aquire a new access token.
    ///
    /// - Returns: a newly created Token initialized to the given values.
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
    ///
    /// - Returns: a newly created Token from the given decoder.
    ///
    /// - Throws: a `DecodingError` if a token cannot be initalized by the given `decoder`.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.access = try container.decode(String.self, forKey: .access)
        self.refresh = try container.decodeIfPresent(String.self, forKey: .refresh)
    }
}

/// Used for categorizing tokens stored in the keychain.
@frozen
public enum TokenType: String {
    /// An access token.
    case access = "access"
    
    /// A refresh token.
    case refresh = "refresh"
}

/// An error that occurs when making authenticated requests.
public enum AuthenticationError: Error {
    /// If a given creadentials value is unable to successfully authenticate.
    case invalidCredentials
    
    /// If authentication fails for any reason with valid credentials.
    case failedToAuthenticate(context: String)
}

extension AuthenticationError: LocalizedError {
    /// The error description shown to the user if authentication fails.
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return String(localized: "Invalid credentials")
        case .failedToAuthenticate(let context):
            return String(localized: "Failed to login, context: \(context)")
        }
    }
}

/// An error that occurs when storing, or retriving values from a KeyChain.
public enum KeychainError: Error {
    /// A password cannot be found in the keychain.
    case noPassword
    
    /// A token cannot be found in the keychain.
    case noToken
    
    /// Password data found in the keychain is corrupted or in the wrong/incorrect forma.t
    case unexpectedPasswordData
    
    /// Token data found in the keychain is corrupted or in the wrong/incorrect format.
    case unexpecetedTokenData
    
    /// An unexpeceted error when retrieving data from the keychain.
    case unhandledError(status: OSStatus)
}

extension KeychainError: LocalizedError {
    /// The error description shown to the user when retrieving user data from the keychain fails.
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
/// - Throws: `KeyhchainError.unhandledError` if storing credentials fails.
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
    
    if server == Server.standard.rawValue {
        return Credentials(username: account, password: password, client_id: "", client_secret: "")
    } else if server == Server.auth.rawValue {
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
private func storeToken(_ token: String, for user: String, ofType type: String) throws {
    let tokenData = token.data(using: String.Encoding.utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "\(user)/\(type)",
        kSecAttrLabel as String: type,
        kSecValueData as String: tokenData
    ]
    
    let status = SecItemCopyMatching(query as CFDictionary, nil)
    if (status == errSecItemNotFound) {
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    } else {
        try updateToken(for: user, ofType: type, token)
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
/// 
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

/// Removes an item from the Keychain.
///
/// - Parameter query: a Keychain query for a specified item.
///
/// - Throws: `KeychainError.unhandledError`if the item at the query does not exist.
private func deleteKeyChainItem(_ query: [String: Any]) throws {
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
}

extension MangaDexAPIRequest {
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
    public func authenticatedGet(from url: URL) async throws -> ModelType {
        guard let token = try? getToken(ofType: TokenType.access.rawValue) else { throw KeychainError.noToken }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.httpShouldHandleCookies = true
        request.timeoutInterval = 90
        
        request.httpMethod = "GET"
        
        var (data, response) = try await URLSession.shared.data(for: request)
        
        if (response as? HTTPURLResponse)?.statusCode == 401 {
            do {
                let _ = try await ReAuthenticationRequest().execute()
                guard let token = try? getToken(ofType: TokenType.access.rawValue) else { throw KeychainError.noToken }
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                (data, response) = try await URLSession.shared.data(for: request)
            }  catch let keychainError as KeychainError {
                // promt user to login
                print(keychainError.localizedDescription)
            } catch AuthenticationError.invalidCredentials {
                // unable to login alert
            } catch { throw AuthenticationError.failedToAuthenticate(context: "\(String(data: data, encoding: .utf8) ?? "no context available").") }
        }
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw httpError((response as! HTTPURLResponse), context: "\(String(data: data, encoding: .utf8) ?? "no context available").")
        }
        
        return try decode(data)
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
    ///
    /// - Throws: `KeychainError.noToken` if an access token cannot be found.
    /// - Throws: ``httpError(_:context:)``  if returned status code is not 200.
    public func authenticatedPost(at url: URL, for value: String? = nil, with content: Data? = nil) async throws {
        guard let token = try? getToken(ofType: TokenType.access.rawValue) else { throw KeychainError.noToken }
        
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
                let _ = try await ReAuthenticationRequest().execute()
                guard let token = try? getToken(ofType: TokenType.access.rawValue) else { throw KeychainError.noToken }
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                (data, response) = try await URLSession.shared.data(for: request)
            } catch let keychainError as KeychainError {
                // promt user to login
                print(keychainError.localizedDescription)
            } catch AuthenticationError.invalidCredentials {
                // unable to login alert
            } catch { throw AuthenticationError.failedToAuthenticate(context: "\(String(data: data, encoding: .utf8) ?? "no context available").") }
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
    public func authenticatedDelete(at url: URL) async throws -> ModelType {
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
                let _ = try await ReAuthenticationRequest().execute()
                guard let token = try? getToken(ofType: TokenType.access.rawValue) else { throw KeychainError.noToken }
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                (data, response) = try await URLSession.shared.data(for: request)
            } catch let keychainError as KeychainError {
                // promt user to login
                print(keychainError.localizedDescription)
            } catch AuthenticationError.invalidCredentials {
                // unable to login alert
            } catch { throw AuthenticationError.failedToAuthenticate(context: "\(String(data: data, encoding: .utf8) ?? "no context available").") }
        }
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw httpError((response as! HTTPURLResponse), context: "\(String(data: data, encoding: .utf8) ?? "no context available").")
        }
        
        return try decode(data)
    }
}

/// Some JSON data containing up to two OAuth tokens, one for accessing authenitcated calls, and one for obtaining access tokens.
struct TokenEntity: MangaDexAPIEntity {
    typealias ModelType = Token?
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.auth.rawValue
        components.path = "/realms/mangadex/protocol/openid-connect/token"
        return components.url!
    }
    
    var requiresAuthentication: Bool { true }
}

/// A request that fetches an access and refresh token for a given user.
/// 
/// - Important: This entity has a custom request type, passing it with the generic request type
///              will leading to a decoding error.
struct LoginRequest: MangaDexAPIRequest {
    /// The credentials of the user logging in.
    ///
    /// A users credentials inclues thier username, password, client id, and client secret.
    let credentials: Credentials
    
    /// The entity that will be fetched by this requests execute method.
    let entity: TokenEntity
    
    /// Creates a new login request for the given credentials
    ///
    /// - Parameters:
    ///     - credentials: The credentials to be used to login.
    ///     - entity: the entity to be fetched by this request, initialized by default.
    ///
    /// - Returns: a newly created LoginRequest for the given credentials.
    init(credentials: Credentials, entity: TokenEntity = TokenEntity()) {
        self.credentials = credentials
        self.entity = entity
    }
    
    /// Attempts to store a users credentials and token in the KeyChain.
    ///
    /// - Parameters:
    ///     - credentials: a credentials value that will have each of its members stored in the Keychain.
    ///     - token: a token value that will have all of its non-nil members stored in the Keychain.
    ///
    /// - Throws: an associated `KeyChainError` if either credentials or token cannot be stored in the Keychain
    private func store(credentials: Credentials, and token: Token) throws {
        try storeToken(token.access, for: credentials.username, ofType: TokenType.access.rawValue)
        if let refresh = token.refresh { try storeToken(refresh, for: credentials.username, ofType: TokenType.refresh.rawValue) }
        try storeCredentials(credentials.username, credentials.password, for: Server.standard.rawValue)
        try storeCredentials(credentials.client_id, credentials.client_secret, for: Server.auth.rawValue)
    }
    
    /// Logs in to the MangaDexAPI with the given credentials, stores the returned token or tokens in the Keychain if successful.
    ///
    /// - Parameter credentials: the credentials to login with.
    ///
    /// - Throws: `AuthenticationError.invalidCredentials` if a users credentials cannot be properly encoded, or passed to the MangaDex API.
    private func login(with credentials: Credentials) async throws {
        guard let content = "grant_type=password&username=\(credentials.username)&password=\(credentials.password)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8) else { throw AuthenticationError.invalidCredentials }
        
        do {
            let data = try await post(at: entity.url, forContentType: "application/x-www-form-urlencoded", with: content)
            let token = try decode(data)
            try store(credentials: credentials, and: token!)
        } catch let decodingError as DecodingError {
            handleDecodingError(decodingError)
        } catch let keychainError { print(keychainError.localizedDescription) }
    }
    
    typealias ModelType = Token?
    
    func decode(_ data: Data) throws -> Token? {
        return try JSONDecoder().decode(Token.self, from: data)
    }
    
    func execute() async throws -> Token? {
        try await login(with: self.credentials)
        return nil
    }
}

/// A request that fetches a new access token for a user.
///
/// This type of request should only be made if an authenticated request fails with error code 401 as  to avoid
/// wasting calls and bandwidth trying to refresh tokens every fifteen minutes.
struct ReAuthenticationRequest: MangaDexAPIRequest {
    /// Fetches an entity that is virtually identical to the one returned by a login request,
    /// thus the `TokenEntity` type can be reused here.
    ///
    /// - Note: This request is also convienienty made at same endpoint as a login request,
    ///     with the only difference being the HTTP form to be filled out.
    let entity: TokenEntity
    
    /// Creates a new ReAuthenticationRequest prepopulated with a TokenEntity value.
    ///
    /// - Parameter entity: the entity to be fetched by this request., initialized by default.
    ///
    /// - Returns - a newly created ReAuthenticationRequest.
    init(entity: TokenEntity = TokenEntity()) {
        self.entity = entity
    }
    
    /// Updates the access token stored in the Keychain by replacing the stored access token with the fetched one.
    ///
    /// - Throws: an associated   `KeyChainError` if the new access token could not be stored.
    private func update(token: String, ofType type: String, for username: String) throws {
        try updateToken(for: username, ofType: type, token)
    }
    
    /// Fetches a new access token to be stored in the Keychain.
    ///
    /// - Throws: `KeychainError.noToken` if a refresh token cannot be found.
    /// - Throws: `KeyChainError.noPassword` if credentials cannot be found.
    /// - Throws: `AuthenticationError.invalidCredentials`  if a users credentials or refresh token cannot be properly encoded, or passed to the MangaDex API.
    private func reAuthenticate() async throws {
        guard let token = try? getToken(ofType: TokenType.refresh.rawValue) else { throw KeychainError.noToken }
        guard let credentials = try? getCredentials(for: Server.auth.rawValue) else { throw KeychainError.noPassword }
        
        guard let content = "grant_type=refresh_token&refresh_token=\(token)&client_id=\(credentials.client_id)&client_secret=\(credentials.client_secret)".data(using: .utf8) else { throw AuthenticationError.invalidCredentials }
        
        do {
            let data = try await post(at: entity.url, forContentType: "application/x-www-form-urlencoded", with: content)
            let token = try decode(data)
            try update(token: token!.access, ofType: TokenType.access.rawValue, for: credentials.username)
        } catch let decodingError as DecodingError {
            handleDecodingError(decodingError)
        } catch let KeyChainError {
            print(KeyChainError.localizedDescription)
        }
    }

    typealias ModelType = Token?
    
    func decode(_ data: Data) throws -> Token? {
        return try JSONDecoder().decode(Token.self, from: data)
    }
    
    func execute() async throws -> Token? {
        try await reAuthenticate()
        return nil
    }
}

