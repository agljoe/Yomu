//
//  AuthorEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-25.
//

import Foundation

/// An entity representing the necessary components for fetching a specifed author.
///
/// - Note: This can also be used to fetch an artist.
struct AuthorEntity: MangaDexAPIEntity {
    /// The UUID of the author to be fetched.
    var id: UUID
    
    typealias ModelType = Author
    
    var url: URL {
        var compontents = URLComponents()
        compontents.scheme = "https"
        compontents.host = "api.mangadex.org"
        compontents.path = "/author/\(id.uuidString.lowercased())"
        compontents.queryItems = [
            URLQueryItem(name: "includes[]", value: "manga")
        ]
        return compontents.url!
    }
    
    var requiresAuthentication: Bool { false }
}
