//
//  MangaStatisticsEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-05.
//

import Foundation

/// An entity representing the necessary components for fetching the statistics associated with a specific manga.
///
/// This entity uses a custom request type, and is thus marked as private.
private struct MangaStatisticsEntity: MangaDexAPIEntity {
    /// The UUID of the manga whose statistics are being retrieved.
    var id: UUID
    
    typealias ModelType = MangaStatistics
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/statistics/manga/\(id.uuidString.lowercased())"
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}

/// A request that returns the statistics for a specific manga
struct MangaStatisticsRequest {
    /// The entity whose statistics are being retieved.
    fileprivate let entity: MangaStatisticsEntity
    
    /// Creates a new instance with the given id.
    ///
    /// This request initalizes its own entity to ensure that a `MangaStatisicsEntity`
    /// is not accidentally passed with a genereic request.
    ///
    /// - Parameter id: The UUID of a manga.
    ///
    /// - Returns: a newly created MangaStatisticsRequest for the given chapter UUID.
    init(for id: UUID) {
        self.entity = .init(id: id)
    }
}

extension MangaStatisticsRequest: MangaDexAPIRequest {
    typealias ModelType = MangaStatistics
    
    func decode(_ data: Data) throws -> MangaStatistics {
        return try JSONDecoder().decode(StatisticsWrapper<MangaStatistics>.self, from: data).statistics
    }
    
    func execute() async throws -> MangaStatistics {
        return try await get(from: entity.url)
    }
}
