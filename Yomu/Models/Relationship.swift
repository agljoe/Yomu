//
//  Relationship.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-08-23.
//

import Foundation

enum AuthorRelationshipType: String, Decodable {
    /// A ``Manga``
    case manga
}

enum AuthorRelationship: Decodable, Equatable, Hashable {
    /// ``AuthorRelationshipType/manga``
    case manga(CompactManga?)
    
    /// The base coding keys for this type.
    private enum CodingKeys: CodingKey {
        case id, type, attributes
    }
    
    /// The nested coding keys found through the attributes keypath.
    ///
    /// Includes all the same attribute coding keys as a Manga.
    private enum AttributeCodingKeys: CodingKey {
        case title, altTitles, description, isLocked, links, originalLanguage, lastVolume, lastChapter, publicationDemographic, status, year, contentRating, tags, state, chapterNumbersResetOnNewVolume, createdAt, updatedAt, version, availableTranslatedLanguages, latestUploadedChapter
    }
    
    /// Creates a new instance by decoding from the given decoer.
    ///
    /// - Parameter decoder: the decoder to read data from.
    ///
    /// - Returns: a newly created AuthorRelationship from the given decoder.
    ///
    /// - Throws: a ` DeodingError` if an AuthorRelationship cannot be initialized by the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let relationshipType = try container.decode(AuthorRelationshipType.self, forKey: .type)
        switch relationshipType { case .manga: self = .manga(try? CompactManga(from: decoder)) }
    }
}

/// All possible types in a manga's reference expansion collection.
///
/// ### See
/// [Reference Expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
enum MangaRelationshipType: String, Decodable {
    /// An ``Author``
    case author
    
    /// An ``Author``
    case artist
    
    /// A ``Cover``
    case cover_art
    
    /// A ``RelatedManga``
    case manga
    
    /// A ``User``
    case creator
}

/// Maps a ``MangaRelationshipType`` to its respective struct.
enum MangaRelationship: Decodable, Equatable, Hashable {
    /// ``MangaRelationshipType/author``
    case author(Author)
    
    /// ``MangaRelationshipType/artist``
    case artist(Author)
    
    /// ``MangaRelationshipType/cover_art``
    case cover_art(Cover)
    
    /// ``MangaRelationshipType/manga``
    case manga(RelatedManga)
    
    /// ``MangaRelationshipType/creator``
    case creator(User)
    
    /// The base coding keys for this type.
    private enum CodingKeys: CodingKey {
        case id, type, attributes, relationships, related
    }
    
    /// The nested coding keys found through the attributes keypath.
    ///
    /// Includes all attribute coding keys for the author, cover, related manga, and user structs.
    private enum AttributesCodingKeys: CodingKey {
        case name, imageUrl, biography, twitter, pixiv, melonBook, fanBox, booth, nicoVideo, skeb, fantia, tumblr, youtube, weibo, naver, namicomi, website, volume, fileName, description, locale, createdAt, updatedAt, version, username, roles
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: the decoder to read data from.
    ///
    /// - Returns: a newly created MangaRelationship from the given decoder.
    ///
    /// - Throws: a ` DeodingError` if a MangaRelationship cannot be initialized by the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let relationshipType = try container.decode(MangaRelationshipType.self, forKey: .type)
        
        switch relationshipType {
        case .author:
            self = .author(try Author(from: decoder))
        case .artist:
            self = .artist(try Author(from: decoder))
        case .cover_art:
            self = .cover_art(try Cover(from: decoder))
        case .manga:
            self = .manga(try RelatedManga(from: decoder))
        case .creator:
            self = .creator(try User(from: decoder))
        }
    }
}


/// All possible types in a chapters' reference expansion collection.
///
/// ### See
/// [Reference Expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
enum ChapterRelationshipType: String, Decodable, Sendable {
    /// A ``ScanlationGroup``
    case scanlation_group
    
    /// A ``User``
    case user
    
    /// A ``ParentManga``
    case manga
}

/// Maps a ``ChapterRelationshipType`` to its respective struct.
enum ChapterRelationship: Decodable, Equatable, Hashable {
    /// ``ChapterRelationshipType/scanlation_group``
    case scanlation_group(ScanlationGroup)
    
    /// ``ChapterRelationshipType/user``
    case user(User)
    
    /// ``ChapterRelationshipType/manga``
    case manga(ParentManga)
    
    /// The base coding keys for this type.
    private enum CodingKeys: CodingKey {
        case id, type, attributes, relationships
    }
    
    /// The nested codingkeys found through the attributes keypath.
    ///
    /// Includes all attribute coding keys for the scanlation group, user, and parent manga structs.
    private enum AttributeCodingKeys: CodingKey {
        case name, username, roles, locked, website, ircServer, ircChannel, discord, contactEmail, description, twitter, mangaUpdates, focusedLanguages, official, verified, inactive, exLisensed, publishDelay, createdAt, updatedAt, version, title, altTitles, originalLanguage
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: the decoder to read data from.
    ///
    /// - Returns: a newly created ChapterRelationship from the given decoder.
    ///
    /// - Throws: a ` DeodingError` if a ChapterRelationship cannot be initialized by the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let relationshipType = try container.decode(ChapterRelationshipType.self, forKey: .type)
        
        switch relationshipType {
        case .scanlation_group:
            self = .scanlation_group(try ScanlationGroup(from: decoder))
        case .user:
            self = .user(try User(from: decoder))
        case .manga:
            self = .manga(try ParentManga(from: decoder))
        }
    }
}
