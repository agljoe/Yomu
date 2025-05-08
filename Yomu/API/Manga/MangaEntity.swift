//
//  MangaEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-04.
//

import Foundation

/// An entity representing the necessary components for fetching a specifed manga.
struct MangaEntity: MangaDexAPIEntity {
    /// The UUID of the manga being retrieved.
    var id: UUID
    
    typealias ModelType = Manga
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.mangadex.org"
        components.path = "/manga/\(id.uuidString.lowercased())"
        components.queryItems = [
            URLQueryItem(name: "includes[]", value: "manga"),
            URLQueryItem(name: "includes[]", value: "cover_art"),
            URLQueryItem(name: "includes[]", value: "author"),
            URLQueryItem(name: "includes[]", value: "artist"),
            URLQueryItem(name: "includes[]", value: "creator")
        ]
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}
