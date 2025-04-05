//
//  MangaListEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-31.
//

import Foundation

/// An entity representing the compontents needed to fetch a collection of specified manga.
struct MangaListEntity: MangaDexAPIEntity {
    /// The UUIDs of the manga to be fetched.
    var ids: [UUID]
    
    /// The maximum size of the returned collection, must be in range 0...100
    var limit: Int
    
    /// The number of items the returned collection is shifted from the first item when this value is zero.
    ///
    /// ### See Also
    var offset: Int
    
    /// The direction the returned collection is sorted in.
    ///
    /// Av
    var order: Order
    
    /// Additional query paramters to be passed with this entity's request.
    ///
    /// This collection can be sorted by title, release year, creation date, most recently updated, most recent chapter upload, total follows, search relevence, or user rating.
    var queryItems: [URLQueryItem]?
    
    init(ids: [UUID], limit: Int = 10, offset: Int = 0, order: Order = Order.desc, queryItems: [URLQueryItem]? = nil) {
        self.ids = ids
        self.limit = limit
        self.offset = offset
        self.order = order
        self.queryItems = queryItems
    }
    
    
    typealias ModelType = [Manga]
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga"
        components.queryItems = [URLQueryItem(name: "limit", value: "\(self.limit)"), URLQueryItem(name: "offset", value: "\(self.offset)")]
        components.queryItems?.append(contentsOf: ids.map { URLQueryItem(name: "includes[]", value: $0.uuidString.lowercased()) })
        
        if let queryItems = self.queryItems {
            components.queryItems?.append(contentsOf: queryItems)
        } else {
            if let contentRating = UserDefaults.standard.object(forKey: "contentRating") as? Rating {
                components.queryItems?.append(contentsOf: contentRating.value)
            }

            components.queryItems?.append(URLQueryItem(name: "order[chapter]", value: self.order.rawValue))
        }
        
        components.queryItems?.append(contentsOf: [
            URLQueryItem(name: "includes[]", value: "cover_art"),
            URLQueryItem(name: "includes[]", value: "author"),
            URLQueryItem(name: "includes[]", value: "artist"),
        ])
                                 
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}
