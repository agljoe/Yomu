//
//  ChapterStatisticsEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-03.
//

import Foundation

/// An entity representing the necessary components for fetching the statistics associated with a specific chatper.
///
/// This entity uses a custom request type, and is thus marked as private.
private struct ChapterStatisticsEntity: MangaDexAPIEntity {
    /// The UUID of the chapter whose statistics are being retrieved.
    var id: UUID
    
    typealias ModelType = ChapterStatistics
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.scheme = Server.standard.rawValue
        components.path = "/statistics/chapter/\(id.uuidString.lowercased())"
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}

/// A request that returns the statistics for a specific chapter
struct ChapterStatisticsRequest {
    /// The entity whose statistics are being retieved.
    fileprivate let entity: ChapterStatisticsEntity
    
    /// Creates a new instance with the given id.
    ///
    /// This request initalizes its own entity to ensure that a `ChapterStatisticsEntity`
    /// is not accidentally passed with a genereic request.
    ///
    /// - Parameter id: The UUID of the a chatper.
    ///
    /// - Returns: a newly created ChapterStatisticsRequest for the given chapter UUID.
    init(for id: UUID) {
        self.entity = .init(id: id)
    }
}

extension ChapterStatisticsRequest: MangaDexAPIRequest {
    typealias ModelType = ChapterStatistics
    
    func decode(_ data: Data) throws -> ChapterStatistics {
        return try JSONDecoder().decode(StatisticsWrapper<ChapterStatistics>.self, from: data).statistics
    }
    
    func execute() async throws -> ChapterStatistics {
        return try await get(from: entity.url)
    }
}
