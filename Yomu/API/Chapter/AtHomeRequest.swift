//
//  AtHomeRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-03.
//

import Foundation

/// An entity representing the necessary compontents for fetching the image URLs of a specific manga.
///
/// - Important: This entity has a custom request type, passing it with the generic request type
///              will leading to a decoding error.
private struct ChapterImageEntity: MangaDexAPIEntity {
    /// The UUID of the chapter whose images are being retrieved.
    var id: UUID
    
    typealias ModelType = AtHomeChapterComponents
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/at-home/server/\(id.uuidString.lowercased())"
        
        if UserDefaults.standard.bool(forKey: "shouldForcePort433") {
            components.queryItems?.append(URLQueryItem(name: "forcePort443", value: "\(true)"))
        }
        
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}

/// Represents a request to the at-home endpoint which is the only endpoint where chapter
/// images can be found.
public struct AtHomeRequest {
    /// The chapter images being retrieved.
    fileprivate let entity: ChapterImageEntity
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter id: the id used to initialize the`ChapterImageEntity` for this request.
    ///
    /// - Returns: a newly created AtHomeRequest for the given id..
    init(for id: UUID) {
        self.entity = ChapterImageEntity(id: id)
    }
}

extension AtHomeRequest: MangaDexAPIRequest {
    public typealias ModelType = AtHomeChapterComponents
    
    public func decode(_ data: Data) throws -> AtHomeChapterComponents {
        return try JSONDecoder().decode(AtHomeChapterComponents.self, from: data)
    }
    
    public func execute() async throws -> AtHomeChapterComponents {
        return try await get(from: entity.url)
    }
    
}
