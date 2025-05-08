//
//  MangaFeedEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-01.
//

import Foundation

/// An entity representing the necessary components for fetching the chapters of a specified manga.
struct MangaFeedEntity: MangaDexAPIEntity {
    /// The UUID of the manga whose chapters are being retrieved.
    var id: UUID
    
    /// The number of chapters to fetch, if this number is larger than
    /// the amount of available chapters the returned collection is simply all available
    /// chapters. This value must be in range 0...500.
    ///
    /// - Note: This value does not represent the true number of chapter in a manga, rather it
    ///         is the total number of availble chapters within the given filters, including multple languages
    ///         or duplicates.
    var limit: Int
    
    /// The number of chapters this collection is shifted from the latest chapter.
    var offset: Int
    
    /// Creates a new instance with the specified UUID.
    ///
    /// - Parameters:
    ///     - id:  the UUID of the manga whose chapters being fetched.
    ///     - limit: the number of chapters to fetch.
    ///     - offset: the chapter number this collection will start at.
    init(id: UUID, limit: Int = 100, offset: Int = 0) {
        self.id = id
        self.limit = limit
        self.offset = offset
    }
    
    typealias ModelType = [Chapter]
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga/\(id.uuidString.lowercased())/feed"
        components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)")]
        
        if let translatedLanguage = UserDefaults.standard.array(forKey: "translatedLanguagee") as? [String] {
            components.queryItems?.append(contentsOf: translatedLanguage.map { URLQueryItem(name: "translatedLanguage[]", value: $0) })
        } else { components.queryItems?.append(URLQueryItem(name: "translatedLanguage[]", value: "en"))}
        
        if let excludedGroups = UserDefaults.standard.array(forKey: "excludedGroupd") as? [String] {
            components.queryItems?.append(contentsOf: excludedGroups.map { URLQueryItem(name: "excludedGroups[]", value: $0) })
        }
        
        if let excludedUploaders = UserDefaults.standard.array(forKey: "excludedUploaders") as? [String] {
            components.queryItems?.append(contentsOf: excludedUploaders.map { URLQueryItem(name: "excludedUploaders[]", value: $0) })
        }
        
        components.queryItems?.append(URLQueryItem(name: "order[chapter]", value: Order.desc.rawValue))
        components.queryItems?.append(contentsOf: [
            URLQueryItem(name: "includes[]", value: "scanlation_group"),
            URLQueryItem(name: "includes[]", value: "user")
        ])
        
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}
