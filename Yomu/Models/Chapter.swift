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
    let externalURL: String?
    
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
    
    /// The base coding keys for this struct.
    private enum CodingKeys: String, CodingKey {
        case id, attributes, relationships
    }
    
    /// The nested coding keys found through the attributes keypath.
    private enum AttributeCodingKeys: String, CodingKey {
        case title, volume, chapter, pages, translatedLanguage, externalUrl, version, createdAt, updatedAt, publishAt, readableAt
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: the decoder to read data from.
    ///
    /// - Returns: a newly created Chapter from the given decoder.
    ///
    /// - Throws: a ` DeodingError` if a Chapter cannot be initialized by the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.title = try attributesContainer.decodeIfPresent(String.self, forKey: .title)
        self.volume = try attributesContainer.decodeIfPresent(String.self, forKey: .volume)
        self.chapter = try attributesContainer.decodeIfPresent(String.self, forKey: .chapter)
        self.pages = try attributesContainer.decode(Int.self, forKey: .pages)
        self.translatedLanguage = try attributesContainer.decode(String.self, forKey: .translatedLanguage)
        self.externalURL = try attributesContainer.decodeIfPresent(String.self, forKey: .externalUrl)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        self.createdAt = try attributesContainer.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try attributesContainer.decode(Date.self, forKey: .updatedAt)
        self.publishAt = try attributesContainer.decode(Date.self, forKey: .publishAt)
        self.readableAt = try attributesContainer.decode(Date.self, forKey: .readableAt)
        
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
    
    /// The base coding keys for this struct.
    private enum CodingKeys: String, CodingKey {
        case id, attributes
    }
    
    /// The nested coding keys found through the attributes keypath.
    private enum AttributeCodingKeys: String, CodingKey {
        case title, originalLanguage
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: the decoder to read data from.
    ///
    /// - Returns: a newly created ParentManga from the given decoder.
    ///
    /// - Throws: a ` DeodingError` if a ParentManga cannot be initialized by the given decoder.
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
    
    /// The base coding keys for this struct.
    private enum CodingKeys: String, CodingKey {
        case result, baseUrl, chapter
    }
    
    /// The nested coding keys found through the chapter keypath.
    private enum ChapterCodingKeys: String, CodingKey {
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
    ///
    /// - Parameter decoder: the decoder to read data from.
    ///
    /// - Returns: a newly created AtHomeChapterComponents  from the given decoder.
    ///
    /// - Throws: a ` DeodingError` if AtHomeChapterComponents  cannot be initialized by the given decoder.
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


/// A chapter stored in a user's local SwiftData library context.
///
/// - Note: This structure's types are made to match the JSON data structure provided in the MangaDexAPI documentation, where
///         optionals are used to represent values that can be null.
@Model
class StoredChapter {
    #Unique<StoredChapter>([\.id])
    #Index<StoredChapter>([\.id], [\.title], [\.title, \.hasBeenRead])
    
    /// A unique id assigned to a chapter.
    @Attribute(.unique, .preserveValueOnDeletion)
    private(set) var id: UUID
    
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
    var externalURL: String?
    
    ///  A number describing the version of a chapter.
    var version: Int

    /// The date a chapter was last modified.
    var updatedAt: Date
    
    /// Sets the read marker for a chapter to false by default.
    var hasBeenRead: Bool
    
    /// The number of pages the user has read.
    var totalReadPages: Int {
        get { hasBeenRead ? pages : 0 }
        set(newValue) { if newValue >= pages { hasBeenRead = true } }
    }
    
    /// A group of people who translated a chapter.
    @Relationship(deleteRule: .cascade)
    var scanlationGroup: StoredScanlationGroup?
    
    /// The user who uploaded this chapter.
    @Relationship(deleteRule: .cascade)
    var user: StoredUser?
    
    /// The manga a chapter is from.
    @Relationship(inverse: \StoredManga.chapters)
    var parentManga: StoredManga?
    
    
    /// Creates a new StoredChapter instance from the given values..
    ///
    /// - Parameters:
    ///     - id: the UUID of a chapter
    ///     - title: the title of a chapter
    ///     - volume: the volume a chapter belongs to.
    ///     - number: the chapter number.
    ///     - pages: the total number of pages in a given chapter.
    ///     - translatedLanguage: the language of a chapter.
    ///     - externalURL: a URL that links to this chapter on a website that is not mangadex.
    ///     - version: the version of this chapter.
    ///     - updatedAt: last time this chapters data was updated on MangaDex.
    ///     - hasBeenRead: indicates if this chapter has been read.
    ///     - scanlationGroup: the group of people who translated this chapter.
    ///     - user: the person who uploaded this chatper to MangaDex.
    ///     - parentManga: the manga a given chapter belongs to.
    ///
    /// - Returns: a newly created StoredChapter.
    init(id: UUID, title: String? = nil, volume: String? = nil, number: String? = nil, pages: Int, translatedLanguage: String, externalURL: String? = nil, version: Int, updatedAt: Date, hasBeenRead: Bool, scanlationGroup: StoredScanlationGroup? = nil, user: StoredUser? = nil, parentManga: StoredManga? = nil) {
        self.id = id
        self.title = title
        self.volume = volume
        self.number = number
        self.pages = pages
        self.translatedLanguage = translatedLanguage
        self.externalURL = externalURL
        self.version = version
        self.updatedAt = updatedAt
        self.hasBeenRead = hasBeenRead
        self.scanlationGroup = scanlationGroup
        self.user = user
        self.parentManga = parentManga
    }
    
    /// Creates a new StoredChapter instance from the given Chapter..
    ///
    /// - Parameters:
    ///     - chapter: the chapter to create a stored instance of.
    ///     - parentManga: the manga the given chapter belongs to.
    ///     - hasBeenRead: a boolean indicating if the given chapter has been read.
    ///
    /// - Returns: a newly created StoredChapter.
    convenience init(from chapter: Chapter, with parentManga: StoredManga? = nil, hasBeenRead: Bool = false) {
        self.init(
            id: chapter.id,
            title: chapter.title,
            volume: chapter.volume,
            number: chapter.chapter,
            pages: chapter.pages,
            translatedLanguage: chapter.translatedLanguage,
            externalURL: chapter.externalURL,
            version: chapter.version,
            updatedAt: chapter.updatedAt,
            hasBeenRead: hasBeenRead,
            parentManga: parentManga
        )
    }

}

extension StoredChapter: Equatable {
    static func == (lhs: StoredChapter, rhs: StoredChapter) -> Bool {
        return lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
}
