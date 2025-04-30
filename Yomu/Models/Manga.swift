//
//  Manga.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation
import SwiftData

/// A Manga.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/Manga/operation/get-manga-id)
struct Manga: Decodable, Equatable, Hashable, Identifiable, Sendable {
    /// A unique id assigned to a manga.
    let id: UUID
    
    /// A title of a manga.
    ///
    /// This value is returned as a localized string, the key for `"title"` is usually `"en"`.
    ///
    let title: [String: String]
    
    /// A collection of localized titles for a manga.
    let altTitles: [[String: String]]
    
    /// A collection of localized descriptions of a manga.
    let description: [String: String]
    
    /// Whether of not this manga is locked.
    let isLocked: Bool
    
    /// Links to manga trackers, and official sources.
    let links: MangaLink
    
    /// The original language of a manga.
    let originalLanguage: String
    
    /// The final volume of a manga.
    let lastVolume: String?
    
    /// The final chapter of a manga.
    ///
    /// - Note: Volume extras, and other bonus content can appear after the final chapter.
    let lastChapter: String?
    
    /// The target audience of a manga.
    ///
    /// ### See
    /// ``Demographic``
    let publicationDemographic: Demographic?
    
    /// The current publication status of a manga.
    ///
    /// ### See
    /// ``Status``
    let status: Status
    
    /// The year a manga was first published,
    let year: Int?
    
    /// The maturity rating of a manga.
    ///
    /// ### See
    /// ``Rating``
    let contentRating: Rating
    
    /// A boolean describing whether the first  chapter in a volume  is denoted "Ch. 1".
    let chapterNumbersResetOnNewVolume: Bool
    
    /// A collection of languages a manga has been translated to.
    let availableTranslatedLanguages: [String]
    
    /// The most recent chapter of a manga.
    let latestUploadedChapter: UUID?
    
    /// A collection of tags for a manga.
    ///
    /// Tags describe the format, genre, themes, and content of a manga.
    let tags: [Tag]
    
    /// The type of publication for a manga.
    let state: String
    
    /// The date a manga was uploaded to MangaDex.
    let createdAt: Date
    
    /// The data a manga was last modified.
    let updatedAt: Date
    
    /// A number describing the version of a manga.
    let version: Int
    
    /// The author or authors of a manga.
    let author: [Author]
    
    /// The artist of artists of a manga.
    let artist: [Author]
    
    /// The cover of a manga.
    let cover: Cover
    
    /// A collection fo manga related to a manga.
    let relatedManga: [RelatedManga]?
    
    /// The user who created this manga's page.
    let creator: User?
    
    private enum CodingKeys: CodingKey {
        case id, attributes, relationships
    }
    
    private enum AttributeCodingKeys: CodingKey {
        case title, altTitles, description, isLocked, links, originalLanguage, lastVolume, lastChapter, publicationDemographic, status, year, contentRating, tags, state, chapterNumbersResetOnNewVolume, createdAt, updatedAt, version, availableTranslatedLanguages, latestUploadedChapter
    }
    
    /// Creates a new instance by decoding from the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.title = try attributesContainer.decode([String: String].self, forKey: .title)
        self.altTitles = try attributesContainer.decode([[String: String]].self, forKey: .altTitles)
        self.description = try attributesContainer.decode([String: String].self, forKey: .description)
        self.isLocked = try attributesContainer.decode(Bool.self, forKey: .isLocked)
        self.links = try attributesContainer.decode(MangaLink.self, forKey: .links)
        self.originalLanguage = try attributesContainer.decode(String.self, forKey: .originalLanguage)
        self.lastVolume = try attributesContainer.decodeIfPresent(String.self, forKey: .lastVolume)
        self.lastChapter = try attributesContainer.decodeIfPresent(String.self, forKey: .lastChapter)
        self.publicationDemographic = try attributesContainer.decodeIfPresent(Demographic.self, forKey: .publicationDemographic)
        self.status = try attributesContainer.decode(Status.self, forKey: .status)
        self.year = try attributesContainer.decodeIfPresent(Int.self, forKey: .year)
        self.contentRating = Rating(rawValue: try attributesContainer.decode(String.self, forKey: .contentRating))!
        self.tags = try attributesContainer.decode([Tag].self, forKey: .tags)
        self.state = try attributesContainer.decode(String.self, forKey: .state)
        self.chapterNumbersResetOnNewVolume = try attributesContainer.decode(Bool.self, forKey: .chapterNumbersResetOnNewVolume)
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone.current
        
        self.createdAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .createdAt))!
        self.updatedAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .updatedAt))!
        
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        self.availableTranslatedLanguages = try attributesContainer.decode([String].self, forKey: .availableTranslatedLanguages)
        self.latestUploadedChapter = try attributesContainer.decodeIfPresent(UUID.self, forKey: .latestUploadedChapter)
        
        var authors: [Author] = []
        var artists: [Author] = []
        var coverArt: Cover?
        var relatedManga: [RelatedManga] = []
        var creator: User?
        
        do {
            let relationships = try container.decodeIfPresent([MangaRelationship].self, forKey: .relationships)
            for relationship in relationships ?? [MangaRelationship]() {
                switch relationship {
                case .author(let author):
                    authors.append(author)
                case .artist(let artist):
                    artists.append(artist)
                case .cover_art(let cover):
                    coverArt = cover
                case .manga(let manga):
                    relatedManga.append(manga)
                case .creator(let user):
                    creator = user
                }
            }
        }
        
        self.author = authors
        self.artist = artists
        self.cover = coverArt!
        self.relatedManga = relatedManga
        self.creator = creator
    }
}

extension Manga {
    static func == (lhs: Manga, rhs: Manga) -> Bool {
        return lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
}

/// An object containing the information of a related manga.
///
/// ### See
/// ``MangaRelated``
struct RelatedManga: Decodable, Equatable, Hashable, Identifiable, Sendable {
    /// A unique id assigned to a manga.
    let id: UUID
    
    /// The type of this object.
    let type: String
    
    /// A description of how this manga is related.
    let related: String
    
    private enum CodingKeys: CodingKey {
        case id
        case type
        case related
    }
    
    /// Creates a new instance by decoding from the given decoder.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
        self.related = try container.decode(String.self, forKey: .related)
    }
}

extension RelatedManga {
    static func == (lhs: RelatedManga, rhs: RelatedManga) -> Bool {
        return lhs.id == rhs.id
    }
}

@Model
class StoredManga {
    /// A unique id assigned to a manga.
    @Attribute(.unique) private(set) var id: UUID
    
    /// A title of a manga.
    ///
    /// This value is returned as a localized string, the key for `"title"` is usually `"en"`.
    ///
    var title: [String: String]
    
    /// A collection of localized titles for a manga.
    var altTitles: [[String: String]]
    
    /// A collection of localized descriptions of a manga.
    var summary: [String: String]
    
    /// Whether of not this manga is locked.
    var isLocked: Bool
    
    /// Links to manga trackers, and official sources.
    var links: [URL]
    
    /// The original language of a manga.
    var originalLanguage: String
    
    /// The final volume of a manga.
    var lastVolume: String?
    
    /// The final chapter of a manga.
    ///
    /// - Note: Volume extras, and other bonus content can appear after the final chapter.
    var lastChapter: String?
    
    /// The target audience of a manga.
    ///
    /// ### See
    /// ``Demographic``
    var publicationDemographic: String?
    
    /// The current publication status of a manga.
    ///
    /// ### See
    /// ``Status``
    var status: Status
    
    /// The year a manga was first published,
    var year: Int?
    
    /// The maturity rating of a manga.
    ///
    /// ### See
    /// ``Rating``
    var contentRating: String
    
    /// A boolean describing whether the first  chapter in a volume  is denoted "Ch. 1".
    var chapterNumbersResetOnNewVolume: Bool
    
    /// A collection of languages a manga has been translated to.
    var availableTranslatedLanguages: [String]
    
    /// The most recent chapter of a manga.
    var latestUploadedChapter: UUID?
    
    /// A collection of tags for a manga.
    ///
    /// Tags describe the format, genre, themes, and content of a manga.
    var tags: [Tag]
    
    /// The type of publication for a manga.
    var state: String
    
    /// The date a manga was uploaded to MangaDex.
    var createdAt: Date
    
    /// The data a manga was last modified.
    var updatedAt: Date
    
    /// A number describing the version of a manga.
    var version: Int
    
    /// The author or authors of a manga.
    @Relationship(deleteRule: .cascade) var author: [StoredAuthor]
    
    /// The artist of artists of a manga.
    @Relationship(deleteRule: .cascade) var artist: [StoredAuthor]
    
    /// The cover of a manga.
    @Relationship(deleteRule: .cascade) var cover: StoredCover
    
    /// A collection fo manga related to a manga.
    var relatedManga: [UUID]?
    
    @Relationship(deleteRule: .cascade) var chapters: [StoredChapter]
    
    init(from manga: Manga) {
        self.id = manga.id
        self.title = manga.title
        self.altTitles = manga.altTitles
        self.summary = manga.description
        self.isLocked = manga.isLocked
        self.links = manga.links.getAvailableLinks()
        self.originalLanguage = manga.originalLanguage
        self.lastVolume = manga.lastVolume
        self.lastChapter = manga.lastChapter
        self.publicationDemographic = manga.publicationDemographic?.rawValue
        self.status = manga.status
        self.year = manga.year
        self.contentRating = manga.contentRating.rawValue
        self.chapterNumbersResetOnNewVolume = manga.chapterNumbersResetOnNewVolume
        self.availableTranslatedLanguages = manga.availableTranslatedLanguages
        self.latestUploadedChapter = manga.latestUploadedChapter
        self.tags = manga.tags
        self.state = manga.state
        self.createdAt = manga.createdAt
        self.updatedAt = manga.updatedAt
        self.version = manga.version
        self.author = manga.author.map({.init(from: $0)})
        self.artist = manga.artist.map({.init(from: $0)})
        self.cover = .init(from: manga.cover)
        self.relatedManga = manga.relatedManga?.map( { $0.id } ) ?? []
        self.chapters = []
    }
}

extension StoredManga: Equatable {
    static func += (lhs: inout StoredManga, rhs: [Chapter]) {
        lhs.chapters.append(contentsOf: rhs.map({ .init(from: $0, with: lhs) }))
    }
    
    static func == (lhs: StoredManga, rhs: StoredManga) -> Bool {
        return lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt && lhs.latestUploadedChapter == rhs.latestUploadedChapter
    }
}
