//
//  CoverListEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-02.
//

import Foundation

/// An entity representing the necessary components for fetching a list of covers.
///
/// Cover lists can be fetched with a list of manga UUIDs, cover UUIDs, or a mix
/// of both.
struct CoverListEntity: MangaDexAPIEntity {
    /// The UUIDs of the manga, whose covers are being retrieved.
    var mangaIDs: [UUID]?
    
    /// The UUIDs of the covers being retrieved.
    var coverIDs: [UUID]?
    
    /// The maximum size of the returned collection, must be in range 0...100
    ///
    /// - Note: The MangaDexAPI will return all available covers for all manga ids passed with a request
    ///         for this entity.
    var limit: Int
    
    /// The number of items the returned collection is shifted from the first item when this value is zero.
    ///
    /// ### See Also
    /// [Pagnation](https://api.mangadex.org/docs/01-concepts/pagination/)
    var offset: Int
        
    /// Creates a new instance for some given manga, or  cover ids.
    ///
    /// - Parameters:
    ///     - mangaIDs: the UUIDs of some manga whose covers to fetch.
    ///     - coverIDs: the UUIDs of the covers to fetch
    ///     - limit: the number of covers to fetch,
    ///     - offset: the starting index of the colleciton  be fetch, 0 by default.
    ///     
    /// - Returns: a newly created CoverListEntity.
    init(mangaIDs: [UUID]? = nil, coverIDs: [UUID]? = nil, limit: Int = 10, offset: Int = 0) {
        self.mangaIDs = mangaIDs
        self.coverIDs = coverIDs
        self.limit = limit
        self.offset = offset
    }
    
    /// Convience initializer that accpects a variadic list of UUIDs.
    ///
    /// - Parameters:
    ///     - mangaIDs: the UUIDs of some manga whose covers to fetch.
    ///     - coverIDs: the UUIDs of the covers to fetch
    ///     - limit: the number of covers to fetch,
    ///     - offset: the starting index of the colleciton to be fetched, 0 by default.
    ///
    /// - Returns: a newly created CoverListEntity.
    init(mangaIDs: UUID..., coverIDs: UUID..., limit: Int = 10, offset: Int = 0) {
        self.init(mangaIDs: mangaIDs, coverIDs: coverIDs, limit: limit, offset: offset)
    }
    
    typealias ModelType = [Cover]
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/cover"
        components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)")]
        
        if let manga = mangaIDs {
            components.queryItems?.append(contentsOf: manga.map { URLQueryItem(name: "manga[]", value: $0.uuidString.lowercased()) })
        }
        
        if let cover = coverIDs {
            components.queryItems?.append(contentsOf: cover.map { URLQueryItem(name: "ids[]", value: $0.uuidString.lowercased()) })
        }
        
        components.queryItems?.append(URLQueryItem(name: "order[volume]", value: Order.desc.rawValue))
        
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}
