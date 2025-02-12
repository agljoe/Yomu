//
//  StatisticsRequests.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-10.
//

import Foundation

/// Retrives and decodes the statistics of a ``Chapter`` specified by the given `id`.
///
/// - Parameter id: the  `UUID` of a specific chapter.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws:  Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: a ``ChapterStatistics`` value for the specfied chapter.
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

public func getStatisticFor(chapters: [UUID]) async throws -> [ChapterStatistics] {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/statistics/chapter"
    
    for id in chapters { components.queryItems?.append(URLQueryItem(name: "chapter[]", value: "\(id.uuidString.lowercased())")) }
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "Url could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable { let statistics: [ChapterStatistics] }
    
    let data = try await get(from: url)
    let result = try JSONDecoder().decode(Root.self, from: data)
    return result.statistics
}
