//
//  Request.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-07.
//

import Foundation

/// An error response from the MangaDexApi.
///
/// The MangaDexApi specifies the exact repsonses for each enpoint, for more information see [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html).
public enum MDApiError: Error, Equatable {
    case unknownResponse(context: String)
    case badRequest(context: String)
    case unauthorizedRequest(context: String)
    case forbiddenRequest(context: String)
    case notFound(context: String)
    case serviceUnavailable(context: String)
    case invalidURL(context: String)
}

extension MDApiError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownResponse(let context):
            return String(localized: "Unknown response recived from server, context: \(context).")
        case .badRequest(let context):
            return String(localized: "Request could not be completed, likely because the format was incorrect, context: \(context).")
        case .unauthorizedRequest(let context):
            return String(localized: "Loged user is not authorized to make this request, context: \(context).")
        case .forbiddenRequest(let context):
            return String(localized: "Request not allowed, context: \(context).")
        case .notFound(let context):
            return String(localized: "Request target could not be found, context: \(context).")
        case .serviceUnavailable(let context):
            return String(localized: "Service is currently unavailable, context: \(context).")
        case .invalidURL(let context):
            return String(localized: "Could not find server at requested URL, context: \(context).")
        }
    }
}

/// Performs an HTTP GET request from a server for the given `url`.
///
/// - Parameters:
///     - url: a url that specifies the sever where the request is made.
/// - Returns: a data value from the specified server.
///
/// - Throws: associated ``httpError(_:context:)`` if returned status code is not 200
public func get(from url: URL) async throws -> Data {
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpShouldHandleCookies = true
    request.timeoutInterval = 90
    
    request.httpMethod = "GET"
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw httpError((response as! HTTPURLResponse), context: "\(String(data: data, encoding: .utf8) ?? "no context available").")
    }
    return data
}

/// Performs an HTTP POST request at a server for the given `url`.
///
/// - Parameters:
///     - url: the url for a specific server.
///     - value: a string specifiying the value of the `Content-Type` header field.
///     - content: an encoded data value passed to a specified server as the request's body.
///
/// > Important: The caller is responsible for encoding the data in the correct format, ensure that the data you are passing is correctly configured for the specified server.
///
/// - Returns: a data value from the specified server.
///
/// - Throws: ``httpError(_:context:)`` if the returned status code is not 200.
public func post(at url: URL, value: String? = nil, content: Data? = nil) async throws -> Data {
    var request = URLRequest(url: url)
    if (value != nil) { request.setValue(value, forHTTPHeaderField: "Content-Type") }
    request.httpShouldHandleCookies = true
    request.timeoutInterval = 90
    request.httpMethod = "POST"
    
    if (content != nil) { request.httpBody = content }
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw httpError((response as! HTTPURLResponse), context: "\(String(data: data, encoding: .utf8) ?? "no context available").")
    }
    
    return data
}

/// Maps an `HTTPRespsonse` to the associated ``MDApiError``
/// - Parameters:
///     - response: an `HTTPURLResponse`
///     - context: a string describing the context in which the error happened
///
/// - Returns: an associated ``MDApiError``.
func httpError(_ response: HTTPURLResponse, context: String) -> MDApiError {
    switch response.statusCode {
    case 400:
        return MDApiError.badRequest(context: context)
    case 401:
        return MDApiError.unauthorizedRequest(context: context)
    case 403:
        return MDApiError.forbiddenRequest(context: context)
    case 404:
        return MDApiError.notFound(context: context)
    case 503:
        return MDApiError.serviceUnavailable(context: context)
    default:
        return MDApiError.unknownResponse(context: context)
    }
}

/// Checks if the MangaDexApi is healthy.
///
/// - Throws: `MDApiError.invalidURL` if a url could not be constructed for a specified server.
/// - Throws: `MDApiError.serviceUnavailable` if the server's response is not pong or there is no response.
///
/// - Returns: the string "pong".
/// ### Endpoint
///     /ping
public func healthCheck() async throws -> String {
    let urlString = "https://api.mangadex.org/ping"
    
    guard let url = URL(string: urlString) else { throw MDApiError.invalidURL(context: "URL could not be constructed from \(urlString)") }
    
    let data = try await get(from: url)
    let response = String(data: data, encoding: .utf8) ?? ""
    
    if response == "pong" { return response } else { throw MDApiError.serviceUnavailable(context: "MangaDex is currently unreachable") }
}
