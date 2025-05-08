//
//  CoverEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-02.
//

import Foundation

/// An entity representing the necessary components for fetching a specified cover.
struct CoverEntity: MangaDexAPIEntity {
    /// The UUID of the cover being retrieved.
    ///
    /// MangaDexAPI documentation states that a this endpoint also accepts
    /// the UUID of a manga, but in reality that does not work. The UUID for the cover
    /// of a given manga can be found in its reference expansion.
    let id: UUID
    
    typealias ModelType = Cover
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/cover/\(id.uuidString.lowercased())"
        components.queryItems = [URLQueryItem(name: "includes[]", value: "manga")]
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}
