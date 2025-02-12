//
//  ChapterRequests.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-02.
//

import Foundation

/// Retrives and decodes a colllection of ``Chapter`` for the given `ids`.
///
/// - Parameters:
///     - ids: a collection of chapter `UUIDs`
///     - queryParameters: an array of `URLQueryItem`for this request.
///
/// - Throws: `MDApiError.badRequest` if limit is greater than 100 or offset is less than 0
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws:  Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: a tuple containing an array of ``Chapter`` and the offset of this collection.
///
/// > Important:
///     See [MangaDex API Redoc](https://api.mangadex.org/docs/redoc.html#tag/Chapter/operation/get-chapter) for a list of available query parameters for this endpoint.
///
///
/// ### Endpoint
///     /chapter
///
/// ### See Also
/// [Reference Expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
///
/// [Pagnation](https://api.mangadex.org/docs/01-concepts/pagination/)
public func getChapters(ids: [UUID], queryParameters: [URLQueryItem] = [URLQueryItem(name: "translatedLanguage[]", value: "en"), URLQueryItem(name: "contentRating[]", value: Rating.safe.rawValue), URLQueryItem(name: "order", value: Order.desc.rawValue), URLQueryItem(name: "includes[]", value: "manga"), URLQueryItem(name: "includes[]", value: "scanlation_group"), URLQueryItem(name: "includes[]", value: "user")] ) async throws -> (chapters: [Chapter], offset: Int)? {
    if ids.count > 100 { throw MDApiError.badRequest(context: "Items are limited to 100 per request.")}
    if ids.isEmpty { return nil }
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/chapter"
    
    if !(queryParameters.contains(where: { $0.name == "limit" })) { components.queryItems = [URLQueryItem(name: "limit", value: "\(ids.count)")] }
    for id in ids { components.queryItems?.append(URLQueryItem(name: "ids[]", value: id.uuidString.lowercased())) }
    components.queryItems?.append(contentsOf: queryParameters)
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable {
        let data: [Chapter]
        let limit: Int
        let offset: Int
        let total: Int
    }
    
    let data = try await get(from: url)
    let chapters = try JSONDecoder().decode(Root.self, from: data)
    
    return (chapters.data, chapters.offset)
}

/// Retrives and decodes  a ``Chapter`` for the given `id`.
///
/// - Parameters:
///     - id: the `UUID` of a specific chapter
///     - queryParameters: an array of `URLQueryItems` for this request.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws:  Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: a ``Chapter``
///
/// > Important:
///     See [MangaDex API Redoc](https://api.mangadex.org/docs/redoc.html#tag/Chapter/operation/get-chapter-id) for a list of available query parameters for this endpoint.
///
/// ### See Also
/// [ReferenceExpansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
/// ### Endpoint
///     /chapter/{id}
public func getChapter(_ id: UUID, queryParameters: [URLQueryItem] = [URLQueryItem(name: "includes[]", value: "manga"), URLQueryItem(name: "includes[]", value: "scanlation_group"), URLQueryItem(name: "includes[]", value: "user")]) async throws -> Chapter {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/chapter/\(id.uuidString.lowercased())"
    components.queryItems?.append(contentsOf: queryParameters)

    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }

    let data = try await get(from: url)
    let chapter = try JSONDecoder().decode(Chapter.self, from: data)
    return chapter
}
