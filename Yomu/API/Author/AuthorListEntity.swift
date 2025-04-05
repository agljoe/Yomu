//
//  AuthorListEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-25.
//

import Foundation

/// An entityrepresenting the necessary components for fetching a specifed collection of authors.
///
/// The returned data will be an array of `Author`
///
/// - Note: This enpoint can aslo fetch a list of artists, or mixed list of authors and artists.
struct AuthorListEntity: MangaDexAPIEntity {
    /// The ids of all authors to be fetched.
    var ids: [UUID]
    
    /// The maximum size of the collection to be fetched, must be in range 0...100.
    var limit: Int
    
    /// The number of items the returned collection is shifted from the first item when this value is zero.
    ///
    /// ### See Also
    /// [Pagnation](https://api.mangadex.org/docs/01-concepts/pagination/)
    var offset: Int
    
    /// The direction the returned collection is sorted in.
    ///
    /// - Note: This collection can only be sorted alphabetically by author name.
    var order: Order
    
    /// Creates a new instance for some given manga, or  cover ids.
    ///
    /// - Parameters:
    ///     - ids: the UUIDs of some manga whose covers are to be fetched.
    ///     - limit: the number of authors, or artists to fetch, 10 by default.
    ///     - offset: the starting index of the collection to be fetched, 0 by default.
    ///     - order: the direction of the sorted collection, descending alphabetically by default.
    init(ids: [UUID], limit: Int = 10, offset: Int = 0, order: Order = Order.desc) {
        self.ids = ids
        self.limit = limit
        self.offset = offset
        self.order = order
    }
    
    typealias ModelType = [Author]
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/author"
        components.queryItems = [URLQueryItem(name: "limit", value: "\(self.limit)"), URLQueryItem(name: "offset", value: "\(self.offset)")]
        components.queryItems?.append(contentsOf: ids.map { URLQueryItem(name: "ids[]", value: $0.uuidString.lowercased() )} )
        components.queryItems?.append(URLQueryItem(name: "order[name]", value: self.order.rawValue))
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}
