//
//  CoverFromMangaListEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-04.
//

import Foundation

/// Shortcut to get the most recent available cover for a manga, when starting from one of its chapters.
///
/// This approach uses the least memroy and API calls, as try to go through the /cover, or /cover{id} endpoints
/// wastes memory decoding uneeded objects, or uses extra calls fetching missing covers.
struct CoverFromMangaWrapper: Decodable {
    /// The UUID of the manga the fetched cover belongs to.
    let parentManga: UUID
    
    /// The cover found in the reference expansion of a manga.
    let cover: Cover
    
    /// Ignore all data found in the returned manga object, and only that the heterogenous
    /// array of JSON objects found in its relationships.
    private enum CodingKeys: CodingKey {
        case id, relationships
    }
    
    /// Creates a new instance by decoding from the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.parentManga = try container.decode(UUID.self, forKey: .id)
        let relationships = try container.decode([MangaRelationship].self, forKey: .relationships)
        var covers = [Cover]()
        
        for relationship in relationships {
            switch relationship {
            case .cover_art(let cover): covers.append(cover)
            default: break
            }
        }
        
        self.cover = covers.first!
    }
}

/// Same as a MangaListEntity, with the goal of fetching a list of covers.
struct CoverFromMangaListEntity: MangaDexAPIEntity {
    /// The UUIDs of the manga whose covers are being fetched.
    var ids: [UUID]
    
    /// The maximum size of the returned collection, must be in range 0...100.
    var limit: Int
    
    /// The number of items the returned collection is shifted from the first item when this value is zero.
    ///
    /// ### See Also
    /// [Pagnation](https://api.mangadex.org/docs/01-concepts/pagination/)
    var offset: Int
    
    /// Creates a new instance with the specified ids.
    ///
    /// - Parameters:
    ///     - ids: the UUIDs of some manga whose covers are to be fetched.
    ///     - limit: the number of covers to fetch, 10 be default.
    ///     - offset: the starting index of the collection to be fetched, 0 by default.
    init(ids: [UUID], limit: Int = 10, offset: Int = 0) {
        self.ids = ids
        self.limit = limit
        self.offset = offset
    }
    
    typealias ModelType = [Cover]
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga"
        components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)")]
        
        components.queryItems?.append(contentsOf: ids.map { URLQueryItem(name: "ids[]", value: $0.uuidString.lowercased()) })
        
        if let contentRating = UserDefaults.standard.object(forKey: "contentRating") as? Rating {
            components.queryItems?.append(contentsOf: contentRating.value)
        }
        
        components.queryItems?.append(contentsOf: [
            URLQueryItem(name: "includes[]", value: "cover_art"),
            URLQueryItem(name: "includes[]", value: "author"),
            URLQueryItem(name: "includes[]", value: "artist"),
            URLQueryItem(name: "includes[]", value: "creator")
        ])
        
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}

/// Requests a list of manga, and returns all the covers found in their reference expansions.
struct CoverListFromMangaRequest {
    /// A custom entity for this request.
    let entity: CoverFromMangaListEntity
    
    /// Creates a new instance with the given entity.
    init(_ entity: CoverFromMangaListEntity) {
        self.entity = entity
    }
}

extension CoverListFromMangaRequest: MangaDexAPIRequest {
    typealias ModelType = [(Cover, UUID)]
    
    func decode(_ data: Data) throws -> [(Cover, UUID)] {
        let covers = try JSONDecoder().decode(Wrapper<[CoverFromMangaWrapper]>.self, from: data)
        return covers.data.map { ($0.cover, $0.parentManga) }
    }
    
    func execute() async throws -> [(Cover, UUID)] {
        return try await get(from: entity.url)
    }
}
