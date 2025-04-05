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
struct ChapterImageEntity: MangaDexAPIEntity {
    /// The UUID of the chapter whose images are being fetched.
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
struct AtHomeRequest {
    /// The chapter images to be fetched.
    let entity: ChapterImageEntity
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter entity: the `ChapterImageEntity` representing the chapter whose
    ///                     images are being requested
    init(entity: ChapterImageEntity) {
        self.entity = entity
    }
}

extension AtHomeRequest: MangaDexAPIRequest {
    typealias ModelType = AtHomeChapterComponents
    
    func decode(_ data: Data) throws -> AtHomeChapterComponents {
        return try JSONDecoder().decode(AtHomeChapterComponents.self, from: data)
    }
    
    func execute() async throws -> AtHomeChapterComponents {
        return try await get(from: entity.url)
    }
    
}
