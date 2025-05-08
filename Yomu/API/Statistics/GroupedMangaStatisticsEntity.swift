//
//  GroupedMangaStatisticsEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-07.
//

import Foundation

/// An entity representing the necessary compontents for fetching the statatistics of multiple manga.
private struct GroupedMangaStatisticsEntity: MangaDexAPIEntity {
    /// The UUIDs of the manga whose statistics are being retrieved.
    var ids: [UUID]
    
    typealias ModelType = MangaStatistics
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/statistics/manga"
        components.queryItems = ids.map( { URLQueryItem(name: "manga[]", value: $0.uuidString.lowercased()) })
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}

/// A request that returns the statistics of multiple manga.
///
/// Grouped statistics are stored as a dictionary with the key being the UUID of the manga for each value respectively.
struct GroupedMangaStatisticsRequest {
    /// The entity whose statistics are being retrieved.
    fileprivate let entity: GroupedMangaStatisticsEntity
    
    /// Creates a new instance with the given ids.
    ///
    /// - Parameter ids: the UUIDs of some manga.
    init(ids: [UUID]) {
        self.entity = .init(ids: ids)
    }
    
    /// Convience initializer that accpects a variadic list of UUIDs.
    ///
    /// - Parameter ids: the UUIDs of some chapters.
    init(ids: UUID...) {
        self.init(ids: ids)
    }
}

extension GroupedMangaStatisticsRequest: MangaDexAPIRequest {
    typealias ModelType = [String: MangaStatistics]
    
    func decode(_ data: Data) throws -> [String : MangaStatistics] {
        return try JSONDecoder().decode(GroupedStatisticsWrapper<MangaStatistics>.self, from: data).statistics
    }
    
    func execute() async throws -> [String : MangaStatistics] {
        return try await get(from: entity.url)
    }
}
