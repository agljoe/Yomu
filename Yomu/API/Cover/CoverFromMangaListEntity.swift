//
//  CoverFromMangaListEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-04.
//

import Foundation

struct CoverFromMangaWrapper: Decodable {
    let cover: Cover

    enum CodingKeys: CodingKey {
        case data
    }
    
    enum DataCodingKeys: CodingKey {
        case relationships
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        let relationships = try dataContainer.decode([MangaRelationship].self, forKey: .relationships)
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

struct CoverFromMangaListEntity: MangaDexAPIEntity {
    var ids: [UUID]
    var limit: Int
    var offset: Int
    
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
        
        components.queryItems?.append(URLQueryItem(name: "includes[]", value: "cover_art"))
        
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}

struct CoverListFromMangaRequest {
    let entity: CoverFromMangaListEntity
    
    init(_ entity: CoverFromMangaListEntity) {
        self.entity = entity
    }
}

extension CoverListFromMangaRequest: MangaDexAPIRequest {
    typealias ModelType = [Cover]
    
    func decode(_ data: Data) throws -> [Cover] {
        let covers = try JSONDecoder().decode([CoverFromMangaWrapper].self, from: data)
        return covers.map { $0.cover }
    }
    
    func execute() async throws -> [Cover] {
        return try await get(from: entity.url)
    }
}
