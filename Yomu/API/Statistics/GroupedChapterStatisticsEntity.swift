//
//  GroupedChapterStatisticsEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-07.
//

import Foundation

/// An entity representing the necessary compontents for fetching the statatistics of multiple chatpters.
private struct GroupedChapterStatisticsEntity: MangaDexAPIEntity {
    /// The UUIDs of the chapters whose statistics are being retrieved.
    var ids: [UUID]
    
    typealias ModelType = ChapterStatistics
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/statistics/chapter"
        components.queryItems = ids.map( { URLQueryItem(name: "chapter[]", value: $0.uuidString.lowercased())} )
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}

/// A request that returns the statistics of multiple chapters.
///
/// Grouped statistics are stored as a dictionary with the key being the UUID of the chapter for each value respectively.
struct GroupedChapterStatisticsRequest {
    /// The entity whose statistics are being retrieved.
    fileprivate let entity: GroupedChapterStatisticsEntity
    
    /// Creates a new instance with the given ids.
    ///
    /// - Parameter ids: the UUIDs of some chapters.
    init(ids: [UUID]) {
        self.entity = .init(ids: ids)
    }
    
    /// Convience initializer that accpects a variadic list of UUIDs.
    ///
    /// - Parameter ids: the UUIDs of some chapters .
    init(ids: UUID...) {
        self.init(ids: ids)
    }
}

extension GroupedChapterStatisticsRequest: MangaDexAPIRequest {
    typealias ModelType = [String: ChapterStatistics]
    
    func decode(_ data: Data) throws -> [String : ChapterStatistics] {
        return try JSONDecoder().decode(GroupedStatisticsWrapper<ChapterStatistics>.self, from: data).statistics
    }
    
    func execute() async throws -> [String : ChapterStatistics] {
        return try await get(from: entity.url)
    }
}
