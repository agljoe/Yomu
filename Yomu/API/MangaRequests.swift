//
//  MangaRequests.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-02.
//

import Foundation

/// Retrives and decodes  a collection of ``Manga`` for the given `ids`.
///
/// - Parameters:
///     - ids: a collection of manga `UUIDs`
///     - queryParameters: an array of `URLQueryItems` for this request.
///
/// - Throws: `MDApiError.badRequest` if limit is greater than 100 or offset is less than 0
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws:  Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: a tuple containing an array of ``Manga`` and the offset of this collection.
///
/// > Important:
///     See [MangaDex API Redoc](https://api.mangadex.org/docs/redoc.html#tag/Manga/operation/get-search-manga) for a list of available query parameters for this endpoint.
///
/// ### Endpoint
///     /manga
///
/// ### See Also
/// [Reference Expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
///
/// [Pagnation](https://api.mangadex.org/docs/01-concepts/pagination/)

public func getManga(ids: [UUID], queryParameters: [URLQueryItem] = [URLQueryItem(name: "contentRating", value: Rating.safe.rawValue), URLQueryItem(name: "includes[]", value: "cover_art"), URLQueryItem(name: "includes[]", value: "cover_art")]) async throws -> (manga: [Manga], offset: Int)? {
    if ids.count > 100 { throw MDApiError.badRequest(context: "Items are limited to 100 per request.")}
    if ids.isEmpty { return nil }
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga"
    
    if !(queryParameters.contains(where: { $0.name == "limit" })) { components.queryItems = [URLQueryItem(name: "limit", value: "\(ids.count)")]}
    for id in ids { components.queryItems?.append(URLQueryItem(name: "ids[]", value: id.uuidString.lowercased())) }
    components.queryItems?.append(contentsOf: queryParameters)
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable {
        let data: [Manga]
        let limit: Int
        let offset: Int
        let total: Int
    }
    
    let data = try await get(from: url)
    let manga = try JSONDecoder().decode(Root.self, from: data)
    return (manga.data, manga.offset)
}

/// Retrives and decodes  a ``Manga`` for the given `id`.
///
/// - Parameter id: the`UUID`of a specific manga.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws: Some `DeocdingError`if the recived JSON data could not be decoded.
///
/// - Returns: a ``Manga``.
///
/// > Important:
///     See [MangaDex API Redoc](https://api.mangadex.org/docs/redoc.html#tag/Manga/operation/get-manga-id) for a list of available query parameters for this endpoint.
///
///  ### Endpoint
///     /manga/{id}
public func getManga(_ id: UUID ) async throws -> Manga {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/\(id.uuidString.lowercased())"
    components.queryItems = [
        URLQueryItem(name: "includes[]", value: "cover_art"),
        URLQueryItem(name: "includes[]", value: "artist"),
        URLQueryItem(name: "includes[]", value: "author")
    ]
    
    struct Root: Decodable { let data: Manga }
    
    guard let url = components.url else{
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    let data = try await get(from: url)
    let manga = try JSONDecoder().decode(Root.self, from: data)
    return manga.data
}

/// Adds a ``Manga`` to a users followed list for the given`id`.
///
/// - Parameter id: the `UUID` of a specific manga.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws: Some `DeocdingError`if the recived JSON data could not be decoded.
///
///  ### Endpoint
///     /manga/{id}/follow
public func followManga(_ id: UUID) async throws {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.managadex.org"
    components.path = "/manga/\(id.uuidString.lowercased())/follow"
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    try await authPost(at: url, for: "application/json")
}

/// Removes a ``Manga`` from a users followed list for the given `id`.
///
/// - Parameter id: the `UUID` of a specific manga.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws: Some `DeocdingError`if the recived JSON data could not be decoded.
///
///  ### Endpoint
///     /manga/{id}/follow
public func unfollowManga(_ id: UUID) async throws {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.managadex.org"
    components.path = "/manga/\(id.uuidString)/unfollow"
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    try await authDelete(at: url)
}

/// Updates the reading status for a  ``Manga`` forthe given `id`.
///
/// - Parameters:
///     - id: the `UUID` of a specific manga.
///     - status: any ``ReadingStatus``.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws: Some `DeocdingError`if the recived JSON data could not be decoded.
///
///  ### Endpoint
///     /manga/{id}/follow
public func updateMangaReadingStatus(for id: UUID, to status: ReadingStatus) async throws {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.managadex.org"
    components.path = "/manga/\(id.uuidString.lowercased())/status"
    
    guard let url = components.url else{
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Data: Codable, Sendable { let status: String }
    
    let content = try JSONEncoder().encode(Data(status: ReadingStatus.RawValue(status.rawValue)))
    try await authPost(at: url, for: "application/json", with: content)
}

/// Retrives and decodes a collection of ``Chapter`` for the given manga's `id`.
///
/// - Parameter id: the `UUID` of a specific manga.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws: Some `DeocdingError`if the recived JSON data could not be decoded.
///
/// - Returns: an array of``Chapter``.
///
///  ### Endpoint
///     /manga/{id]/feed
public func getChapters(for id: UUID) async throws -> [Chapter] {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/\(id.uuidString.lowercased())/feed"
    
    guard let url = components.url else{
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    let data = try await get(from: url)
    let chapters = try JSONDecoder().decode([Chapter].self, from: data)
    return chapters
}

/// Gets a random manga.
///
/// - Parameter queryParameters: an array of `URLQueryItems` for this request.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws: Some `DeocdingError`if the recived JSON data could not be decoded.
///
/// - Returns: A ``Manga``.
///
/// > Important:
///     See [MangaDex API Redoc](https://api.mangadex.org/docs/redoc.html#tag/Manga/operation/get-manga-random) for a list of available query parameters for this endpoint.
///
/// ### Endpoint
///     /random
public func getRandomManga(queryParameters: [URLQueryItem] = [URLQueryItem(name: "includes[]", value: "manga"), URLQueryItem(name: "includes[]", value: "cover_art"), URLQueryItem(name: "includes[]", value: "author"), URLQueryItem(name: "includes[]", value: "artist"), URLQueryItem(name: "includes[]", value: "tag"), URLQueryItem(name: "contentRating[]", value: Rating.safe.rawValue)]) async throws -> Manga {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/random"
    components.queryItems = queryParameters
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable { let data: Manga }
    
    let data = try await get(from: url)
    let manga = try JSONDecoder().decode(Root.self, from: data)
    return manga.data
}

/// Gets alll available manga tags.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws: Some `DeocdingError`if the recived JSON data could not be decoded.
///
/// - Returns: A tuple containg an array of ``Tag``s and the size of this collection.
///
/// ### Endpoint
///     /manga/tag
public func getTags() async throws -> (tags: [Tag], total: Int) {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/tag"
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable {
        let data: [Tag]
        let limit: Int
        let offset: Int
        let total: Int
    }
    
    let data = try await get(from: url)
    let tags = try JSONDecoder().decode(Root.self, from: data)
    return (tags.data, tags.total)
}

/// Gets a collection of manga ids with an associated status.
///
///  By default the MangaDex API will return all manga with their associated status, filtering this collection will  reduce memory
///  usage while increasing API calls.
///
/// - Parameter status: The ``ReadingStatus`` used to filter this collection.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws: Some `DeocdingError`if the recived JSON data could not be decoded.
///
/// - Returns: An array of `UUID:String` key pairs.
///
/// ### Endpoint
///     /manga/status
public func getMangaForUserReadingStatus(_ status: ReadingStatus? = nil) async throws -> [[UUID: String]] {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/status"
    
    if let status { components.queryItems = [URLQueryItem(name: "status", value: status.rawValue)] }
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable { let statuses: [[UUID: String]] }
    
    let data = try await authGet(from: url)
    let result = try JSONDecoder().decode(Root.self, from: data)
    return result.statuses
}
