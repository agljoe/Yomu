//
//  Chapter.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-11.
//

import Foundation
import SwiftData

/// A chapter of a manga.
///
///  Chapter objects returned by the MangaDex do not include chapter images. See [Find a Manga's Chapters](https://api.mangadex.org/docs/04-chapter/feed/).
///
/// - Note: This structure's types are made to match the JSON data structure provided in the MangaDexAPI documentation, where
///         optionals are used to represent values that can be null.
///
///  ### See Also
///  [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/Chapter/operation/get-chapter-id)
struct Chapter: Decodable, Identifiable, Sendable {
    /// A unique id assigned to a chapter.
    let id: UUID
    
    /// The title of this chapter
    let title: String?
    
    /// The volume which a chapter belongs to.
    let volume: String?
    
    /// A chapter's number.
    let chapter: String?
    
    /// The number of pages in a chapter.
    let pages: Int
    
    /// The language a chapter is in.
    let translatedLanguage: String
    
    /// A chapter that links to an eternal source.
    let externalUrl: String?
    
    ///  A number describing the version of a chapter.
    let version: Int
    
    /// The date a chapter was uploaded to MangaDex.
    let createdAt: Date
    
    /// The date a chapter was last modified.
    let updatedAt: Date
    
    /// The date a chapter was published.
    let publishAt: Date
    
    /// The date a chapter was available to read.
    let readableAt: Date
    
    /// A group of people who translated a chapter.
    let scanlationGroup: ScanlationGroup?
    
    /// The user who uploaded this chapter.
    let user: User?
    
    /// The manga a chapter is from.
    let parentManga: ParentManga?
    
    /// Sets the read marker for a chapter to false by default.
    var hasBeenRead: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id, attributes, relationships
    }
    
    private enum AttributeCodingKeys: String, CodingKey {
        case title, volume, chapter, pages, translatedLanguage, externalUrl, version, createdAt, updatedAt, publishAt, readableAt
    }
    
    /// Creates a new instance by decoding from the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.title = try attributesContainer.decodeIfPresent(String.self, forKey: .title)
        self.volume = try attributesContainer.decodeIfPresent(String.self, forKey: .volume)
        self.chapter = try attributesContainer.decodeIfPresent(String.self, forKey: .chapter)
        self.pages = try attributesContainer.decode(Int.self, forKey: .pages)
        self.translatedLanguage = try attributesContainer.decode(String.self, forKey: .translatedLanguage)
        self.externalUrl = try attributesContainer.decodeIfPresent(String.self, forKey: .externalUrl)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone.current
        
        self.createdAt =  RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .createdAt))!
        self.updatedAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .updatedAt))!
        self.publishAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .publishAt))!
        self.readableAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .readableAt))!
        
        var scanlationGroup: ScanlationGroup?
        var uploader: User?
        var parentManga: ParentManga?
        
        do {
            let relationships = try container.decodeIfPresent([ChapterRelationship].self, forKey: .relationships)
            for relationship in relationships ?? [ChapterRelationship]() {
                switch relationship {
                case .scanlation_group(let scanlation_group):
                    scanlationGroup = scanlation_group
                case .user(let user):
                    uploader = user
                case .manga(let manga):
                    parentManga = manga
                }
            }
        }
        
        self.scanlationGroup = scanlationGroup ?? nil
        self.user = uploader ?? nil
        self.parentManga = parentManga ?? nil
    }
    
    mutating func updateReadMarker(to marker: Bool) {
        self.hasBeenRead = marker
    }
}

extension Chapter {
    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        return lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
}

/// A value obtained from the reference expansion of a ``Chapter``.
///
/// ### See Also
/// [Reference Expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
struct ParentManga: Decodable, Equatable, Hashable, Identifiable, Sendable {
    /// A unique UUID assinged to a ``Manga``.
    let id: UUID
    
    /// The localized title of a ``Manga``.
    ///
    /// - Note: This value may only be romanized.
    let title: [String: String]? // TODO: flatten to just string
    
    /// The original language of this manga.
    let originalLanuage: String?
    
    enum CodingKeys: String, CodingKey {
        case id, attributes
    }
    
    enum AttributeCodingKeys: String, CodingKey {
        case title, originalLanguage
    }
    
    /// Creates a new instance by decoding from the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        if container.contains(.attributes) {
            let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
            self.title = try attributesContainer.decode([String: String].self, forKey: .title)
            self.originalLanuage = try attributesContainer.decode(String.self, forKey: .originalLanguage)
        } else {
            self.title = nil
            self.originalLanuage = nil
        }
    }
}

extension ParentManga {
    static func == (lhs: ParentManga, rhs: ParentManga) -> Bool {
        return lhs.id == rhs.id
    }
}

/// A group of `URLComponents` used to dynamically construct chapter image URLs.
///
/// - Warning: Do not extract complete URLs from this structure, hardcoding URLs is never recommended.
///            See [MangaDex Api Documentation](https://api.mangadex.org/docs/04-chapter/retrieving-chapter/#about-hardcoding-base-urls).
///
/// ### See Also
/// [Retreving a chapter's images](https://api.mangadex.org/docs/04-chapter/retrieving-chapter/)
struct AtHomeChapterComponents: Decodable, Equatable, Hashable, Sendable {
    /// A string describing the result of retriving this data, "ok" if successful.
    let result: String
    
    /// The base URL for retriving images in this collection.
    ///
    ///  - Important:  Base URLs are valid for 15 minutes. For more information see [MangaDex API Documentation](https://api.mangadex.org/docs/04-chapter/retrieving-chapter/#howto).
    let baseUrl: String
    
    /// The hash value for this chapter.
    let hash: String
    
    /// A collection of URL paths to high quality chapter images.
    let data: [String]
    
    /// A collection of URL paths to low quality chapter images.
    let dataSaver: [String]
    
    enum CodingKeys: String, CodingKey {
        case result, baseUrl, chapter
    }
    
    enum ChapterCodingKeys: String, CodingKey {
        case hash, data, dataSaver
    }
    
    init() {
        self.result = ""
        self.baseUrl = ""
        self.hash = ""
        self.data = []
        self.dataSaver = []
    }
    
    /// Creates a new instance by decoding from the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.result = try container.decode(String.self, forKey: .result)
        self.baseUrl = try container.decode(String.self, forKey: .baseUrl)
        
        let chapterContainer = try container.nestedContainer(keyedBy: ChapterCodingKeys.self, forKey: .chapter)
        self.hash = try chapterContainer.decode(String.self, forKey: .hash)
        self.data = try chapterContainer.decode([String].self, forKey: .data)
        self.dataSaver = try chapterContainer.decode([String].self, forKey: .dataSaver)
        
    }
}

@Model
class StoredChapter {
    /// A unique id assigned to a chapter.
    @Attribute(.unique) private(set)
    var id: UUID
    
    /// The title of this chapter
    var title: String?
    
    /// The volume which a chapter belongs to.
    var volume: String?
    
    /// A chapter's number.
    var number: String?
    
    /// The number of pages in a chapter.
    var pages: Int
    
    /// The language a chapter is in.
    var translatedLanguage: String
    
    /// A chapter that links to an eternal source.
    var externalUrl: String?
    
    ///  A number describing the version of a chapter.
    var version: Int
    
    /// The date a chapter was uploaded to MangaDex.
    var createdAt: Date
    
    /// The date a chapter was last modified.
    var updatedAt: Date
    
    /// The date a chapter was published.
    var publishAt: Date
    
    /// The date a chapter was available to read.
    var readableAt: Date
    
    /// A group of people who translated a chapter.
    @Relationship(deleteRule: .cascade) var scanlationGroup: StoredScanlationGroup?
    
    /// The user who uploaded this chapter.
    @Relationship(deleteRule: .cascade) var user: StoredUser?
    
    /// The manga a chapter is from.
    @Relationship(inverse: \StoredManga.chapters) var parentManga: StoredManga?
    
    /// Sets the read marker for a chapter to false by default.
    var hasBeenRead: Bool = false
    
    /// Creates a new StoredChapter.
    init(from chapter: Chapter, with parentManga: StoredManga? = nil) {
        self.id = chapter.id
        self.title = chapter.title
        self.volume = chapter.volume
        self.number = chapter.chapter
        self.pages = chapter.pages
        self.translatedLanguage = chapter.translatedLanguage
        self.externalUrl = chapter.externalUrl
        self.version = chapter.version
        self.createdAt = chapter.createdAt
        self.updatedAt = chapter.updatedAt
        self.publishAt = chapter.publishAt
        self.readableAt = chapter.readableAt
        self.parentManga = parentManga
        self.hasBeenRead = chapter.hasBeenRead
    }
}
