//
//  FollowedFeedEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-04.
//

import Foundation

/// An entity representing the necesary components for fetching chapters from a user's followed manga feed.
struct FollowedFeedEntity: MangaDexAPIEntity {
    /// The maximum size of the returned collection, must be in range 0...500.
    var limit: Int
    
    /// The number of items the retuned collection is shifted from the latest available chapter in this feed.
    ///
    /// ### See Also
    /// [Pagnation](https://api.mangadex.org/docs/01-concepts/pagination/)
    var offset: Int
    
    /// Creates a new instance with default values.
    ///
    /// - Parameters:
    ///     - limit: the number of chapters to fetch, 100 by default.
    ///     - offset: the starting index of the colleciton, 0 by default.
    init(limit: Int = 100, offset: Int = 0) {
        self.limit = limit
        self.offset = offset
    }
    
    typealias ModelType = [Chapter]
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/user/follows/manga/feed"
        components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)")]
        
        if let translatedLanuage = UserDefaults.standard.array(forKey: "translatedLanguage") as? [String] {
            components.queryItems?.append(contentsOf: translatedLanuage.map { URLQueryItem(name: "translatedLanguage[]", value: $0) })
        } else { components.queryItems?.append(URLQueryItem(name: "translatedLanguage[]", value: "en")) }
        
        if let orginalLanuage = UserDefaults.standard.array(forKey: "originalLanguage") as? [String] {
            components.queryItems?.append(contentsOf: orginalLanuage.map { URLQueryItem(name: "originalLanguage[]", value: $0) })
        }
        
        if let exclucedOriginalLanuage = UserDefaults.standard.array(forKey: "excludedOriginalLanguage") as? [String] {
            components.queryItems?.append(contentsOf: exclucedOriginalLanuage.map { URLQueryItem(name: "excludedOriginalLanguage[]", value: $0) })
        }
        
        if let contentRating = UserDefaults.standard.object(forKey: "contentRating") as? Rating {
            components.queryItems?.append(contentsOf: contentRating.value)
        }
        
        if let excludedGroups = UserDefaults.standard.array(forKey: "excludedGroups") as? [UUID] {
            components.queryItems?.append(contentsOf: excludedGroups.map { URLQueryItem(name: "excludedGroups[]", value: $0.uuidString.lowercased()) })
        }
        
        if let excludedUploades = UserDefaults.standard.array(forKey: "excludedUploaders") as? [UUID] {
            components.queryItems?.append(contentsOf: excludedUploades.map { URLQueryItem(name: "excludingUploaders[]", value: $0.uuidString.lowercased()) })
        }
        
        components.queryItems?.append(contentsOf: [
            URLQueryItem(name: "order[publishAt]", value: Order.desc.rawValue),
            URLQueryItem(name: "includes[]", value: "manga"),
            URLQueryItem(name: "includes[]", value: "scanlation_group"),
            URLQueryItem(name: "includes[]", value: "user")
        ])
        
        return components.url!
    }
    
    var requiresAuthentication: Bool { true }
}
