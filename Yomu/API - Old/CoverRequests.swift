//
//  CoverRequests.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-02.
//

import Foundation

/// Retrives and decodes a collection of ``Cover`` for the given  `ids`.
///
/// - Parameters:
///     - ids: a collection of chapter `UUIDs`
///     - queryParameters: an array of `URLQueryItems` for this request.
///
/// > Important:
///     See [MangaDex API Redoc](https://api.mangadex.org/docs/redoc.html#tag/Cover) for a list of available query parameters for this endpoint.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws: Some `DeocdingError`if the recived JSON data could not be decoded.
///
/// - Returns: a tuple containing an array of ``Cover`` and the offset of this collection.
///
///  ### Endpoint
///     /cover/
public func getCoversFor(ids: [UUID], queryParameters: [URLQueryItem] = [URLQueryItem(name: "order[createdAt]", value: "desc"), URLQueryItem(name: "order[updatedAt]", value: "desc"), URLQueryItem(name: "order[volume]", value: "desc")]) async throws -> (covers: [Cover], offest: Int) {
    if (ids.count > 100) { throw MDApiError.badRequest(context: "Ids are limited to 100 per request.")}
    if (ids.isEmpty) { return ([], 0) }
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/cover"
    
    if !(queryParameters.contains(where: { $0.name == "limit" })) { components.queryItems = [URLQueryItem(name: "limit", value: "\(ids.count)")] }
    for id in ids { components.queryItems?.append(URLQueryItem(name: "manga[]", value: id.uuidString.lowercased())) }
    components.queryItems?.append(contentsOf: queryParameters)
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable {
        let data: [Cover]
        let limit: Int
        let offset: Int
        let total: Int
    }
    
    let data = try await get(from: url)
    let covers = try JSONDecoder().decode(Root.self, from: data)
    return (covers.data, covers.offset)
}

/// Retrives and decodes  a ``Cover`` for the given `id`.
///
/// - Parameter id: the `UUID`of a specific cover.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws: Some `DeocdingError`if the recived JSON data could not be decoded.
///
/// - Returns: a ``Cover``
///
///  ### Endpoint
///     /cover/{id}
public func getCoverFor(_ id: UUID) async throws -> Cover {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/cover/\(id.uuidString.lowercased())"
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable { let data: Cover } // TODO: refactor to CoverEntity
    
    let data = try await get(from: url)
    let cover = try JSONDecoder().decode(Root.self, from: data)
    return cover.data
}
