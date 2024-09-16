//
//  Relationship.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-08-23.
//

import Foundation

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

enum ChapterRelationshipType: String, Decodable {
    case scanlation_group
    case user
}

enum ChapterRelationship: Decodable {
    case scanlation_group(ScanlationGroup)
    case user(User)
    
    enum CodingKeys: CodingKey {
        case id, type, name, attributes, relationships
    }
    
    enum AttributeCodingKeys: CodingKey {
        case name, username, roles, locked, website, ircServer, ircChannel, discord, contactEmail, description, twitter, mangaUpdates, focusedLanguages, official, verified, inactive, exLisensed, publishDelay, createdAt, updatedAt, version
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let relationshipType = try container.decode(ChapterRelationshipType.self, forKey: .type)
        
        switch relationshipType {
        case .scanlation_group:
            self = .scanlation_group(try ScanlationGroup(from: decoder))
        case .user:
            self = .user(try User(from: decoder))
        }
    }
}

