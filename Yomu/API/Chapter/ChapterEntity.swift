//
//  ChapterEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-29.
//

import Foundation

/// An entity that represents the components needed to fetch a specific chapter of a manga.
struct ChapterEntity: MangaDexAPIEntity {
    /// The UUID of a specific chapter
    var id: UUID
    
    typealias ModelType = Chapter
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/chapter\(id.uuidString.lowercased())"
        components.queryItems = [
            URLQueryItem(name: "includes[]", value: "manga"),
            URLQueryItem(name: "includes[]", value: "scanlation_group"),
            URLQueryItem(name: "includes[]", value: "user")
        ]
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}
