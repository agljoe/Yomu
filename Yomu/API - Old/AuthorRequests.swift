//
//  AuthorRequests.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-02.
//

import Foundation

/// Retrives and decodes a collection of `Author` for the given `ids`.
///
/// MangaDex only makes a distinction between authors, and artists with ``Author/type``.
///  The endpoint, and JSON struction is otherwise identical.
///
/// - Parameters:
///     - ids: a collection of author or artist `UUIDs`.
///     - queryParameters: an array of `URLQueryItems` for this request.
///
/// - Throws: `MDApiError.badRequest` if limit is greater than 100 or offset is less than 0
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws:  Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: a tuple containing an array of ``Author`` and the offset of this collection.
///
/// > Important:
///     See [MangaDex API Redoc](https://api.mangadex.org/docs/redoc.html#tag/Author/operation/get-author) for a list of available query parameters for this endpoint.
///
///
/// ### Endpoint
///     /author
///
/// ### See Also
/// [Reference Expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
///
/// [Pagnation](https://api.mangadex.org/docs/01-concepts/pagination/)
public func getAuthors(ids: [UUID], queryParameters: [URLQueryItem] = [URLQueryItem(name: "includes[]", value: "manga")]) async throws -> (authors: [Author], offset: Int) {
    if ids.count > 100 { throw MDApiError.badRequest(context: "Items are limited to 100 per request.") }
    if ids.isEmpty { return ([], 0) }
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/author"
    
    if !(queryParameters.contains(where: { $0.name == "limit" })) { components.queryItems = [URLQueryItem(name: "limit", value: "\(ids.count)")] }
    for id in ids { components.queryItems?.append(URLQueryItem(name: "ids[]", value: id.uuidString.lowercased())) }
    components.queryItems?.append(contentsOf: queryParameters)
    
    guard let url = components.url else { throw MDApiError.invalidURL(context: "Url could not be constructed from components:\(components.string ?? "no components").") }
    
    struct Root: Decodable {
        let data: [Author]
        let limit: Int
        let offset: Int
        let total: Int
    }
    
    let data = try await get(from: url)
    let authors = try JSONDecoder().decode(Root.self, from: data)
    return (authors.data, authors.offset)
}

/// Retrives and decodes a ``Author`` for the given `id`.
///
/// MangaDex only makes a distinction between authors, and artists with ``Author/type``.  
///  The endpoint, and JSON struction is otherwise identical.
///
/// - Parameters:
///     - id: the `UUID` of a specific author or artist.
///     - queryParameters: an array of `URLQueryItems` for this request.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws: Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: an ``Author``
///
/// > Important:
///     See [MangaDex API Redoc](https://api.mangadex.org/docs/redoc.html#tag/Author/operation/get-author-id) for a list of available query parameters for this endpoint.
///
/// ### Endpoint
///     /author/{id}
///
/// ### See Also
/// [Reference Expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
public func getAuthor(_ id: UUID, queryParameters: [URLQueryItem] = [URLQueryItem(name: "inclues[]", value: "manga")]) async throws -> Author {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/author/\(id.uuidString.lowercased())"
    components.queryItems?.append(contentsOf: queryParameters)
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "Url could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable { let data: Author }
    
    let data = try await get(from: url)
    let author = try JSONDecoder().decode(Root.self, from: data)
    return author.data
}
