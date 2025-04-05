//
//  MangaReadingStatus.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-02.
//

import Foundation

/// Wraps a returned reading status string so it can decoded.
///
/// The returned value will be a `ReadingStatus` raw value.
///
/// - Important: This entity has a custom request type, passing it with the generic request type
///              will leading to a decoding error.
struct ReadingStatusWrapper: Decodable { let status: String}

/// An enitty representing the necessary components for fetching the reading status of a specified manga.
struct ReadingStatusEntity: MangaDexAPIEntity {
    /// The UUID of the manga whose reading status is being fetched.
    var id: UUID
    
    typealias ModelType = String
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "manga/\(id.uuidString.lowercased())/status"
        return components.url!
    }
    
    var requiresAuthentication: Bool { true }
}

/// A request that returns a string describing the reading status of a manga.
struct MangaReadingStatusRequest {
    /// The enitty whose reading status is being fetched/
    let entity: ReadingStatusEntity
    
    /// Craetes a new instance for the specified entity.
    ///
    /// - Parameter entity: The entity to 
    init(for entity: ReadingStatusEntity) {
        self.entity = entity
    }
}

extension MangaReadingStatusRequest: MangaDexAPIRequest {
    typealias ModelType = String
    
    func decode(_ data: Data) throws -> String {
        return try JSONDecoder().decode(ReadingStatusWrapper.self, from: data).status
    }
    
    func execute() async throws -> String {
        return try await authenticatedGet(from: self.entity.url)
    }
}

/// Wraps the returned reading status dictionary so it can be decoded.
///
/// The returned dictionary is formated such that the key is a manga's UUID string,
/// and the value is reading status.
struct ReadingStatusCollectionWrapper: Decodable { let statuses: [String: String] }

/// A request that fetches a dictionary containing the reading status for all manga in a user's library.
struct AllMangaReadingStatusRequest: MangaDexAPIRequest {
    typealias ModelType = [String: String]
    
    func decode(_ data: Data) throws -> [String : String] {
        return try JSONDecoder().decode(ReadingStatusCollectionWrapper.self, from: data).statuses
    }
    
    func execute() async throws -> [String : String] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "manga/status"
        return try await authenticatedGet(from: components.url!)
    }
}
