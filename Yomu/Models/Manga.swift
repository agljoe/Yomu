//
//  Manga.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation
import SwiftData

/// A comic of Japanese origin, read from left to right.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/Manga/operation/get-manga-id)
struct Manga: Decodable, Equatable, Hashable, Identifiable, Sendable {
    /// A unique id assigned to a manga.
    let id: UUID
    
    /// A name of a manga.
    ///
    /// - Note: This value is returned as a localized string, the key for `"title"` is usually `"en"`.
    let title: [String: String]
    
    /// A collection of localized titles.
    let altTitles: [[String: String]]
    
    /// A short summary of this manga's premise, often available in multple languages.
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
    
    /// A boolean describing whether the first  chapter in each volume  is denoted "Ch. 1".
    let chapterNumbersResetOnNewVolume: Bool
    
    /// A collection of languages a manga has been translated to.
    let availableTranslatedLanguages: [String]
    
    /// The most recent chapter of a manga.
    let latestUploadedChapter: UUID?
    
    /// A collection of tags describing the genres, themes, and content in a manga.
    let tags: [Tag]
    
    /// The type of publication.
    let state: String
    
    /// The date a manga was first uploaded to MangaDex.
    let createdAt: Date
    
    /// The data a manga was last modified.
    let updatedAt: Date
    
    /// A number describing the number of updates a manga has had.
    let version: Int
    
    /// The author or authors of a manga.
    let author: [Author]
    
    /// The artist of artists of a manga.
    let artist: [Author]
    
    /// The most recent cover of a manga.
    let cover: Cover
    
    /// A collection fo manga related to this manga.
    let relatedManga: [RelatedManga]?
    
    /// The user who created this manga's page.
    let creator: User?
    
    /// Indicates whether or not this manga is currently being read.
    var readingStatus: ReadingStatus = .none
    
    /// Indicates if new chapters of this manga appears in a user's followed manga chapter feed.
    var isFollowed: Bool = false
    
    /// The base coding keys for this struct.
    private enum CodingKeys: CodingKey {
        case id, attributes, relationships
    }
    
    /// The nested coding keys found through the attributes keypath.
    private enum AttributeCodingKeys: CodingKey {
        case title, altTitles, description, isLocked, links, originalLanguage, lastVolume, lastChapter, publicationDemographic, status, year, contentRating, tags, state, chapterNumbersResetOnNewVolume, createdAt, updatedAt, version, availableTranslatedLanguages, latestUploadedChapter
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: the decoder to read data from.
    ///
    /// - Returns: a newly created Manga from the given decoder.
    ///
    /// - Throws: a ` DeodingError` if a Manga cannot be initialized by the given decoder.
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
        self.createdAt = try attributesContainer.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try attributesContainer.decode(Date.self, forKey: .updatedAt)
        
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        self.availableTranslatedLanguages = try attributesContainer.decode([String].self, forKey: .availableTranslatedLanguages)
        self.latestUploadedChapter = try attributesContainer.decodeIfPresent(UUID.self, forKey: .latestUploadedChapter)
        
        var authors: [Author?] = []
        var artists: [Author?] = []
        var coverArt: Cover?
        var relatedManga: [RelatedManga?] = []
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
        
        self.author = authors.compactMap( {$0} )
        self.artist = artists.compactMap( {$0} )
        self.cover = coverArt!
        self.relatedManga = relatedManga.compactMap( {$0} )
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
    
    /// The base coding keys for this struct.
    private enum CodingKeys: CodingKey {
        case id, type, related
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: the decoder to read data from.
    ///
    /// - Returns: a newly created Related from the given decoder.
    ///
    /// - Throws: a ` DeodingError` if a Related cannot be initialized by the given decoder.
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

extension Array where Element == [String: String]  {
    /// Reduces the weird array of dictionaries returned by the MangaDexAPi into a single dictionary where
    /// each key leads to all available alternate titles for te respective language.
    func flattenAltTitles() -> [String: [String]] {
        var flattenedDictionary: [String: [String]] = [:]

        for element in self {
            if let _ = flattenedDictionary[element.keys.first!] {
                flattenedDictionary[element.keys.first!]!.append(element.values.first!)
            } else {
                flattenedDictionary.updateValue([element.values.first!], forKey: element.keys.first!)
            }

        }
        
        return flattenedDictionary
    }
}

/// A manga stored in a user's local SwiftData library context.
///
/// - Note: This structure's types are made to match the JSON data structure provided in the MangaDexAPI documentation, where
///         optionals are used to represent values that can be null.
@Model
class StoredManga {
    #Unique<StoredManga>([\.id], [\.id, \.updatedAt])
    #Index<StoredManga>([\.id], [\.title])
    
    /// A unique id assigned to a manga.
    @Attribute(.unique, .preserveValueOnDeletion)
    private(set) var id: UUID
    
    /// A name of a manga.
    ///
    /// This value is returned as a localized string, the key for `"title"` is usually `"en"`.
    ///
    var title: String
    
    /// A collection of localized titles.
    var altTitles: [String: [String]]
    
    /// A collection of localized descriptions of a manga.
    var summary: [String: String]
    
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
    var publicationDemographic: Demographic?
    
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
    
    /// A boolean describing whether the first  chapter in each volume is denoted "Ch. 1".
    var chapterNumbersResetOnNewVolume: Bool
    
    /// A collection of languages a manga has been translated to.
    var availableTranslatedLanguages: [String]
    
    /// The most recent chapter of a manga.
    var latestUploadedChapter: UUID?
    
    /// A collection of tags describing the genres, themes, and content in a manga.
    @Relationship(deleteRule: .cascade)
    var tags: [StoredTag]
    
    /// The type of publication.
    var state: String
    
    /// The data a manga was last modified.
    var updatedAt: Date
    
    /// A number describing the number of updates a manga has had..
    var version: Int
    
    /// The user's  current reading status for this manga.
    var readingStatus: ReadingStatus
    
    /// Indicated if this manga's chapters appear in a user's followed manga chapter feed.
    var isFollowed: Bool
    
    /// A collection of manga related to a manga.
    var relatedManga: [UUID]?
    
    /// The author or authors of a manga.
    @Relationship(deleteRule: .cascade)
    var author: [StoredAuthor]
    
    /// The artist of artists of a manga.
    @Relationship(deleteRule: .cascade)
    var artist: [StoredAuthor]
    
    /// The most recent cover of a manga.
    @Relationship(deleteRule: .cascade)
    var cover: StoredCover
    
    @Relationship(deleteRule: .cascade)
    /// The chapters of a manga.
    var chapters: [StoredChapter]
    
    
    /// Creates a new StoredManga instance from the given values.
    ///
    /// - Parameters
    ///     - id: the UUID of a manga.
    ///     - title: the title of a manga.
    ///     - altTitles: the title of a manga in other languages.
    ///     - summary: a brief description of a manga.
    ///     - links: URLs for this manga on related websites.
    ///     - original language: the original language of a manga.
    ///     - last volume: the final volume of a manga.
    ///     - last chapter: the final chapter of a manga.
    ///     - publicationDemographic: the target audience of a manga.
    ///     - status: the current publication status of a manga.
    ///     - year: the year a manga was first published.
    ///     - contentRating: the maturity of content depicted in a manga.
    ///     - chapterNumbersResetOnNewVolume: if a manga has every volume start at chapter one.
    ///     - availableTranslatedLanguages: the langauges a manga has been translated into.
    ///     - latestUploadedChapter: the most reacently uloaded chatper of a manga.
    ///     - tags: the genres and themes of a manga.
    ///     - state: a manga's publication state.
    ///     - updatedAt: the last time this manga was updated on MangaDex.
    ///     - version: the version of a manga.
    ///     - readingStatus: a user's reading status for this manga.
    ///     - isFollowed: inidcates if this manga's chapters appear in a user's followed manga chapter feed.
    ///     - relatedManga: any managa related to this manga's universe
    ///     - author: the author of this manga.
    ///     - artist: the artist of this magna,
    ///     - cover: a cover art for this manga.
    ///     - chapters: the available chapters for this manga.
    ///
    /// - Returns: a newly created StoredManga.
    init(id: UUID, title: String, altTitles: [String : [String]], summary: [String : String], links: [URL], originalLanguage: String, lastVolume: String? = nil, lastChapter: String? = nil, publicationDemographic: Demographic? = nil, status: Status, year: Int? = nil, contentRating: String, chapterNumbersResetOnNewVolume: Bool, availableTranslatedLanguages: [String], latestUploadedChapter: UUID? = nil, tags: [StoredTag], state: String, updatedAt: Date, version: Int, readingStatus: ReadingStatus, isFollowed: Bool, relatedManga: [UUID]? = nil, author: [StoredAuthor], artist: [StoredAuthor], cover: StoredCover, chapters: [StoredChapter]) {
        self.id = id
        self.title = title
        self.altTitles = altTitles
        self.summary = summary
        self.links = links
        self.originalLanguage = originalLanguage
        self.lastVolume = lastVolume
        self.lastChapter = lastChapter
        self.publicationDemographic = publicationDemographic
        self.status = status
        self.year = year
        self.contentRating = contentRating
        self.chapterNumbersResetOnNewVolume = chapterNumbersResetOnNewVolume
        self.availableTranslatedLanguages = availableTranslatedLanguages
        self.latestUploadedChapter = latestUploadedChapter
        self.tags = tags
        self.state = state
        self.updatedAt = updatedAt
        self.version = version
        self.readingStatus = readingStatus
        self.isFollowed = isFollowed
        self.relatedManga = relatedManga
        self.author = author
        self.artist = artist
        self.cover = cover
        self.chapters = chapters
    }
    
    /// Creates a new StoredManga instance from the given Manga.
    ///
    /// - Parameter manga: the manga to create a stored instance of.
    ///
    /// - Returns: a newly created StoredManga.
    convenience init(from manga: Manga) {
        self.init(
            id: manga.id,
            title: manga.title[manga.title.keys.first ?? "en"] ?? "",
            altTitles: manga.altTitles.flattenAltTitles(),
            summary: manga.description,
            links: manga.links.getAvailableLinks(),
            originalLanguage: manga.originalLanguage,
            lastVolume: manga.lastVolume,
            lastChapter: manga.lastChapter,
            publicationDemographic: manga.publicationDemographic,
            status: manga.status,
            year: manga.year,
            contentRating: manga.contentRating.rawValue,
            chapterNumbersResetOnNewVolume: manga.chapterNumbersResetOnNewVolume,
            availableTranslatedLanguages: manga.availableTranslatedLanguages,
            latestUploadedChapter: manga.latestUploadedChapter,
            tags: manga.tags.map({ .init(from: $0) }),
            state: manga.state,
            updatedAt: manga.updatedAt,
            version: manga.version,
            readingStatus: manga.readingStatus,
            isFollowed: manga.isFollowed,
            relatedManga: manga.relatedManga?.map({ $0.id }) ?? [],
            author: manga.author.map({ .init(from: $0) }),
            artist: manga.artist.map({ .init(from: $0) }),
            cover: .init(from: manga.cover),
            chapters: []
        )
    }
    
    /// Creates a new StoredManga instance from the given CompactManga.
    ///
    /// - Parameters
    ///     - manga: the compact manga to create a stored instance of.
    ///     - cover: the cover of this manga.
    ///     - author: the author(s) of this manga.
    ///     - artist: the artist(s) of thie manga.
    ///     - readingStatus: the user's reading status of a manga.
    ///     - isFollowed: whether or not a user follows a manga.
    ///
    /// - Returns: a newly created StoredManga.
    convenience init(from compactManga: CompactManga, with cover: Cover, author: [Author], artist: [Author], readingStatus: ReadingStatus? = nil, isFollowed: Bool = false) {
        self.init(
            id: compactManga.id,
            title: compactManga.title[compactManga.title.keys.first ?? "en"] ?? "",
            altTitles: compactManga.altTitles.flattenAltTitles(),
            summary: compactManga.description,
            links: compactManga.links.getAvailableLinks(),
            originalLanguage: compactManga.originalLanguage,
            lastVolume: compactManga.lastVolume,
            lastChapter: compactManga.lastChapter,
            publicationDemographic: compactManga.publicationDemographic,
            status: compactManga.status,
            year: compactManga.year,
            contentRating: compactManga.contentRating.rawValue,
            chapterNumbersResetOnNewVolume: compactManga.chapterNumbersResetOnNewVolume,
            availableTranslatedLanguages: compactManga.availableTranslatedLanguages,
            latestUploadedChapter: compactManga.latestUploadedChapter,
            tags: compactManga.tags.map({ .init(from: $0) }),
            state: compactManga.state,
            updatedAt: compactManga.updatedAt,
            version: compactManga.version,
            readingStatus: readingStatus ?? .none,
            isFollowed: isFollowed,
            relatedManga: [],
            author: author.map({ .init(from: $0) }),
            artist: artist.map({ .init(from: $0) }),
            cover: .init(from: cover),
            chapters: []
        )
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
