//
//  StatisticsRequests.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-10.
//

import Foundation

/// Retrives and decodes the statistics of a ``Chapter`` for the given `id`.
///
/// - Parameter id: the  `UUID` of a specific chapter.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws:  Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: a ``ChapterStatistics`` value from the specfied chapter.
/// ### Endpoint
///     /statistics/chapter/[{id}
public func getStatisticsFor(chapter id: UUID) async throws -> ChapterStatistics {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/statistics/chapter/\(id.uuidString.lowercased())"
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "Url could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable { let statistics: ChapterStatistics }
    
    let data = try await get(from: url)
    let result = try JSONDecoder().decode(Root.self, from: data)
    return result.statistics
}

/// Retrives and decodes the statistics of a collection of ``Chapter``for the given `ids`.
///
/// - Parameter ids: a collection of chapter  `UUIDs`.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws:  Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: an array of ``ChapterStatistics`` from the specfied chapters.
/// ### Endpoint
///     /statistics/chapter
public func getStatisticsFor(chapters ids: [UUID]) async throws -> [ChapterStatistics] {
    if ids.isEmpty { return [] }
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/statistics/chapter"
    components.queryItems = []
    
    for id in ids { components.queryItems?.append(URLQueryItem(name: "chapter[]", value: "\(id.uuidString.lowercased())")) }
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "Url could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable { let statistics: [String : [String: [String: Int]]] }
    
    let data = try await get(from: url)
    let result = try JSONDecoder().decode(Root.self, from: data)
    var statistics = [ChapterStatistics]()
    
    for (key, value) in result.statistics {
        statistics.append(ChapterStatistics(id: UUID(uuidString: key)!, threadId: value["comments"]?["threadId"], repliesCount: value["comments"]?["repliesCount"]))
    }
    
    return statistics
}

/// Retrives and decodes the statistics of a ``Manga`` for the given `id`.
///
/// - Parameter id: the  `UUID` of a specific manga.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws:  Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: a ``MangaStatistics`` value from the specfied chapter.
/// ### Endpoint
///     /statistics/manga/{id]
public func getStatisticsFor(manga id: UUID) async throws -> MangaStatistics {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/statistics/manga/\(id.uuidString.lowercased())"
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "Url could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable { let statistics: MangaStatistics }
    
    let data = try await get(from: url)
    let result = try JSONDecoder().decode(Root.self, from: data)
    return result.statistics
}

/// Retrives and decodes the statistics of a collection of ``Manga``for the given `ids`.
///
/// The MangaDex API returns a very oddly formatted nested dictionary with three different types of dictionaries as values
///  for each key. This leads to the very ugly manual mapping from a `[String: Any]` dictionary to the appropriate type.
///
/// - Parameter ids: a collection of chapter  `UUIDs`.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws:  Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: an array of ``MangaStatistics`` from the specfied chapters.
///
/// > Note:
///     Optionals are force unwrapped here as they are assumed to always be present unless this endpoint is drastically changed.
///
/// ### Endpoint
///     /statistics/manga
public func getStatisticsFor(manga ids: [UUID]) async throws -> [MangaStatistics] {
    if ids.isEmpty { return [] }
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/statistics/manga"
    components.queryItems = []
    
    for id in ids { components.queryItems?.append(URLQueryItem(name: "manga[]", value: "\(id.uuidString.lowercased())")) }
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "Url could not be constructed from components: \(components.string ?? "no components").")
    }
    
    let data = try await get(from: url)
    let serialized = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    var result = [MangaStatistics]()
    
    for id in ids {
        let statistics: [String: Any] = serialized["statistics"] as! [String: Any]
        let inner: [String: Any] = statistics["\(id.uuidString.lowercased())"] as! [String: Any]
        let comments: [String: Int] = inner["comments"] as! [String: Int]
        let follows: Int = inner["follows"] as! Int
        let rating: [String: Double] = inner["rating"] as! [String: Double]
        result.append(MangaStatistics(id: id, threadId: comments["threadId"], repliesCount: comments["repliesCount"], average: rating["average"]!, bayesian: rating["bayesian"]!, distribution: nil, follows: follows))
    }
    
    return result
}
