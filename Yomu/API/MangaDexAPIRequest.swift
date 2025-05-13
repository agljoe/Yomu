//
//  MangaDexAPIRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-01.
//

import Foundation

/// JSON encoded data that is fetchable from one of Mangadex's API endpoints.
protocol MangaDexAPIEntity: Sendable {
    /// A model type that matches the structure of the fetched JSON data.
    associatedtype ModelType: Decodable
    
    /// The endpoint where the associated ``ModelType`` can  be fetched from.
    ///
    /// Some endpoints have an available list of query parameters, for more information check the `See Also` section
    /// or the documentation for the specified endpoint at [MangaDexAPI Documentation](https://api.mangadex.org/docs/redoc.html)
    ///
    /// ### See Also
    /// [Reference Expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
    var url: URL { get }
    
    /// Indicates if a user's access token will be passed in the Bearer(token) Authorization header.
    var requiresAuthentication: Bool { get }
}

/// A request to the MangaDex API.
protocol MangaDexAPIRequest {
    /// The model type to be fetched by this request.
    associatedtype ModelType
    
    /// Decodes the given data as the associated model type.
    ///
    /// - Parameter data: some JSON data to be decoded as `ModelType`.
    ///
    /// - Throws: some 'DecodingError'  if `data` cannot be decoded.
    ///
    /// - Returns: the decoded data as the specified model type.
    func decode(_ data: Data) throws -> ModelType
    
    /// Executes this request
    func execute() async throws -> ModelType
}

/// A generic wrapper around data returned from the MangaDex API.
///
/// Endpoints that return collections of data, often include the size limit, and offset of the collection,
/// along with the number of returned items.
struct Wrapper<T: Decodable>: Decodable {
    /// The type 
    let data: T
    
    /// The size limit of collections returned by some endpoint.
    let limit: Int?
    
    /// The item offset of this collection.
    let offset: Int?
    
    /// The total number of items in returned in this collection.
    let total: Int?
}

extension MangaDexAPIRequest {
    /// Performs an HTTP GET request from a server for the given `url`.
    ///
    /// - Parameter url: a url that specifies the sever where the request is made.
    /// - Returns: the data from the server decoded as the specified `ModelType`.
    ///
    /// - Throws: an associated ``httpError(_:context:)`` if returned status code is not 200
    func get(from url: URL) async throws -> ModelType {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = true
        request.timeoutInterval = 90
        
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw httpError((response as! HTTPURLResponse), context: "\(String(data: data, encoding: .utf8) ?? "no context available").")
        }
        
        return try decode(data)
    }
    
    /// Performs an HTTP POST request at a server for the given `url`.
    ///
    /// - Parameters:
    ///     - url: the url for a specific server.
    ///     - value: a string specifiying the value of the `Content-Type` header field.
    ///     - content: an encoded data value passed to a specified server as the request's body.
    ///
    /// > Important: The caller is responsible for encoding the data in the correct format, ensure the data being passed is correctly configured for the specified server.
    ///
    /// - Returns: a data value from the specified server.
    ///
    /// - Throws: ``httpError(_:context:)`` if the returned status code is not 200.
    func post(at url: URL, forContentType value: String = "application/json", with content: Data? = nil) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(value, forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = true
        request.timeoutInterval = 90
        request.httpMethod = "POST"
        
        if let body = content { request.httpBody = body }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw httpError((response as! HTTPURLResponse), context: "\(String(data: data, encoding: .utf8) ?? "no context available").")
        }
        
        return data
    }
    
    /// Creates a JSONDecoder that uses RFC3339 as its date decoding strategy.
    ///
    /// - Returns: A  JSONDecoder with a custom dateDecodingStrategy.
    func mangaDexAPIDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone.current
        decoder.dateDecodingStrategy = .formatted(RFC3339DateFormatter)
        
        return decoder
    }
}

/// Nested error context found in an error response JSON.
struct MangaDexAPIErrorResponse: Decodable {
    /// The id associated with this error.
    let id: String
    
    /// The HTTP status code for this error.
    let status: Int
    
    /// The MangaDexAPI's name for this error.
    let title: String
    
    /// Additional details explaining the causes of this error.
    let detail: String?
    
    /// The circumstances which caused this error to occur.
    let context: String?
}

/// A generic error response from the MangaDexAPI.
struct ErrorResponse: Decodable {
    /// A string that whose value is "error".
    let result: String
    
    /// The errors returned from the requested endpoint.
    let errors: [MangaDexAPIErrorResponse]
}

/// A generic response found at endpoints that do not return any data.
struct Response: Decodable { let result: String }

/// A generic request that fetches the entity specified by `T`.
struct Request<T: MangaDexAPIEntity>: Sendable {
    /// The entity being retrieved by this request.
    let entity: T
    
    /// Creates a new request for the given entity.
    ///
    /// - Parameter entity: a MangaDexAPI entity being retrieved.
    ///
    /// - Returns: a newly created Request for the given entity.
    init(_ entity: T) {
        self.entity = entity
    }
}

extension Request: MangaDexAPIRequest {
    func decode(_ data: Data) throws -> T.ModelType {
        return try mangaDexAPIDecoder().decode(Wrapper<T.ModelType>.self, from: data).data
    }
    
    func execute() async throws -> T.ModelType {
        if entity.requiresAuthentication { return try await authenticatedGet(from: entity.url) }
        return try await get(from: entity.url)
    }
}

/// A generic request that fetches a list from the entity specified by `T`.
///
/// - Important: List requests should be made with this request type, unless the offset of the collection can be discarded.
struct ListRequest<T: MangaDexAPIEntity>: Sendable {
    /// The entity being retrieved by this request.
    let entity: T
    
    /// Creates a new request for the given entity.
    ///
    /// - Parameter entity: a MangaDexAPI entity being retrieved.
    ///
    /// - Returns: a newly created ListRequest for the given entity.
    init(_ entity: T) {
        self.entity = entity
    }
}

extension ListRequest: MangaDexAPIRequest {
    typealias ModelType = (T.ModelType, Int, Int)
    
    func decode(_ data: Data) throws -> (T.ModelType, Int, Int) {
        let result = try mangaDexAPIDecoder().decode(Wrapper<T.ModelType>.self, from: data)
        return (result.data, result.offset ?? 0, result.total ?? 0)
    }
    
    func execute() async throws -> (T.ModelType, Int, Int) {
        if entity.requiresAuthentication { return try await authenticatedGet(from: entity.url) }
        return try await get(from: entity.url)
    }
}


