//
//  MangaDexAPIRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-01.
//

import Foundation

/// JSON encoded data that is fetchable from one of Mangadex's API endpoints.
protocol MangaDexAPIEntity {
    /// A model type that matches the structure of the fetched JSON data.
    associatedtype ModelType: Decodable
    
    /// The endpoint where the associated ``ModelType`` can  be fetched from.
    var path: String { get }
}

/// A request to the MangaDex API.
protocol MangaDexAPIRequest {
    /// The model type to be fetched by this request.
    associatedtype ModelType
    
    /// Decodes the given data as the associated model type.
    ///
    /// - Parameter data: some JSON data to be decoded as ``ModelType``.
    ///
    /// - Throws: some 'DecodingError'  if `data` cannot be decoded.
    ///
    /// - Returns: the decoded data as the specified model type.
    func decode(_ data: Data) throws -> ModelType
    
    /// Requests data.
    func execute() async throws -> ModelType
}

/// A generic wrapper around data returned from the MangaDex API.
///
/// Endpoints that return collections of data, often include the size limit, and offset of the collection,
/// along with the number of returned items.
struct Wrapper<T: Decodable>: Decodable {
    ///
    let data: T
    let limit: Int?
    let offset: Int?
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
    func post(at url: URL, forConentType value: String? = nil, with content: Data? = nil) async throws -> Data {
        var request = URLRequest(url: url)
        if (value != nil) { request.setValue(value, forHTTPHeaderField: "Content-Type") }
        request.httpShouldHandleCookies = true
        request.timeoutInterval = 90
        request.httpMethod = "POST"
        
        if let body = content { request.httpBody = content }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw httpError((response as! HTTPURLResponse), context: "\(String(data: data, encoding: .utf8) ?? "no context available").")
        }
        
        return data
    }

}
