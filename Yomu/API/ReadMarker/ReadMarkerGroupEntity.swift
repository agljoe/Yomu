//
//  ReadMarkerGroupEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-05.
//

import Foundation

/// An entity representing the necessary components for fetching the chapter read markers for
/// a specifed collection of manga.
///
/// This entity can be requested with the generic  `Request` type, and should not be requested
/// as a list.
struct ReadMarkerGroupEntity: MangaDexAPIEntity {
    /// The UUIDs of the manga whose chapter read markers are being retrieved.
    var ids: [UUID]
    
    typealias ModelType = [String: [String]]
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga/read"
        components.queryItems = ids.map { URLQueryItem(name: "ids[]", value: $0.uuidString.lowercased()) }
        components.queryItems?.append(URLQueryItem(name: "grouped", value: "\(true)"))
        return components.url!
    }
    
    var requiresAuthentication: Bool { true }
}
