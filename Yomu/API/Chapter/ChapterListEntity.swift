//
//  ChapterListEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-29.
//

import Foundation

/// An entity representing the necessary components for fetching a specifed collection of chapters.
struct ChapterListEntity: MangaDexAPIEntity {
    /// The UUIDs of the chapters to be fetches.
    var ids: [UUID]
    
    /// The maximum size of the collection to be tetched, must be in range 0...100.
    var limit: Int
    
    /// The number of items the returned collection is shifted from the first item when this value is zero.
    ///
    /// ### See Also
    /// [Pagnation](https://api.mangadex.org/docs/01-concepts/pagination/)
    var offset: Int
    
    /// The direction of the sorted collection.
    ///
    /// This collection can be sorted by creation date, most recently updated, publish date, readable at date, volume number, or chapter number.
    var order: Order
    
    /// Creates a new instance with the given ids.
    ///
    /// - Parameters:
    ///     - ids: An array of UUIDs for each chapter to fetch
    ///     - limit: the number of chapters to fetch, 10 by default.
    ///     - offset: the amount this collection is shifted, 0 by default.
    ///     - order: the direction of this collection's sort.
    init(ids: [UUID], limit: Int = 10, offset: Int = 0, order: Order = Order.desc) {
        self.ids = ids
        self.limit = limit
        self.offset = offset
        self.order = order
    }
    
    typealias ModelType = [Chapter]
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/chapter"
        components.queryItems = [URLQueryItem(name: "limit", value: "\(self.limit)"), URLQueryItem(name: "offset", value: "\(self.offset)")]
        components.queryItems?.append(contentsOf: ids.map { URLQueryItem(name: "ids[]", value: $0.uuidString.lowercased() )} )
        
        if let contentRating = UserDefaults.standard.object(forKey: "contentRating") as? Rating {
            components.queryItems?.append(contentsOf: contentRating.value)
        }
        
        if let translatedLanguages = UserDefaults.standard.array(forKey: "translatedLanguage") as? [String] {
            components.queryItems?.append(contentsOf: translatedLanguages.map { URLQueryItem(name: "translatedLanguage[]", value: $0)})
        } else { components.queryItems?.append(URLQueryItem(name: "translatedLanguage[]", value: "en")) }
        
        if let excludedGroups = UserDefaults.standard.array(forKey: "excludedGroups") as? [UUID] {
            components.queryItems?.append(contentsOf: excludedGroups.map { URLQueryItem(name: "excludedGroups[]", value: $0.uuidString.lowercased()) })
        }
        
        if let excludedUploades = UserDefaults.standard.array(forKey: "excludedUploaders") as? [UUID] {
            components.queryItems?.append(contentsOf: excludedUploades.map { URLQueryItem(name: "excludingUploaders[]", value: $0.uuidString.lowercased()) })
        }
        
        components.queryItems?.append(URLQueryItem(name: "order[name]", value: self.order.rawValue))

        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}
