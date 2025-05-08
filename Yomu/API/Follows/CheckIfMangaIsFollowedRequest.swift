//
//  CheckIfMangaIsFollowedRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-29.
//

import Foundation

/// Represents a request to the /user/follows/manga/{id} endpoint.
///
/// Due to the way this specifc endpoint works the execute fuction will return false if an error was thrown
/// and the decode method will always return true.
struct CheckIfMangaIsFollowedRequest: MangaDexAPIRequest {
    /// The UUID of the manga whose follow status is being checked.
    let id: UUID
    
    typealias ModelType = Bool
    
    func decode(_ data: Data) throws -> Bool {
        return true
    }
    
    func execute() async throws -> Bool {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/user/follows/manga/\(id.uuidString.lowercased())"
    
        do {
            return try await authenticatedGet(from: components.url!)
        } catch {
            return false
        }
    }
}
