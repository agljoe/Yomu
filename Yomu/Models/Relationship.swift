//
//  Relationship.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-08-23.
//

import Foundation

struct RelatedManga: Decodable {
    let id: UUID
    let type: String
    let related: String
}

enum MangaRelationshipType: String, Decodable {
    case author
    case artist
    case cover_art
    case manga
}

enum MangaRelationship: Decodable {
    case author(Author)
    case artist(Artist)
    case cover_art(Cover)
    case manga(RelatedManga)
    
    enum CodingKeys: String, CodingKey {
        case id, type, attributes, relationships, related
    }
    
    enum AttributesCodingKeys: CodingKey {
        case name, imageUrl, biography, twitter, pixiv, melonBook, fanBox, booth, nicoVideo, skeb, fantia, tumblr, youtube, weibo, naver, namicomi, website, volume, fileName, description, locale, createdAt, updatedAt, version
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let relationshipType = try container.decode(MangaRelationshipType.self, forKey: .type)
        
        switch relationshipType {
        case .author:
            self = .author(try Author(from: decoder))
        case .artist:
            self = .artist(try Artist(from: decoder))
        case .cover_art:
            self = .cover_art(try Cover(from: decoder))
        case .manga:
            self = .manga(try RelatedManga(from: decoder))
        }
    }
}
