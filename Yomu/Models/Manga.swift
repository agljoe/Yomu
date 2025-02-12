//
//  Manga.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation

/// A Manga.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/Manga/operation/get-manga-id)
public struct Manga: Decodable, Identifiable, Sendable {
    /// A unique id assigned to a manga.
    public let id: UUID
    
    /// A title of a manga.
    ///
    /// This value is returned as a localized string, the key for `"title"` is usually `"en"`.
    ///
    let title: [String: String]
    
    /// A collection of localized titles for a manga.
    let altTitles: [[String: String]]
    
    /// A collection of localized descriptions of a manga.
    let description: [[String: String]]
    
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
    /// >Note: Volume extras, and other bonus content can appear after the final chapter.
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
    let author: [Author]?
    
    /// The artist of artists of a manga.
    let artist: [Author]?
    
    /// The cover of a manga.
    let cover: Cover?
    
    /// A collection fo manga related to a manga.
    let relatedManga: [RelatedManga]?
    
    private enum CodingKeys: CodingKey {
        case id, attributes, relationships
    }
    
    private enum AttributeCodingKeys: CodingKey {
        case title, altTitles, description, isLocked, links, originalLanguage, lastVolume, lastChapter, publicationDemographic, status, year, contentRating, tags, state, chapterNumbersResetOnNewVolume, createdAt, updatedAt, version, availableTranslatedLanguages, latestUploadedChapter
    }
    
    /// Creates a ``Manga`` instance initialized with placeholder values.
    public init() {
        self.id = UUID()
        self.title = [:]
        self.altTitles = [[:]]
        self.description = [[:]]
        self.isLocked = false
        self.links = MangaLink(al: "", ap: "", bw: "", mu: "", nu: "", kt: "", amz: "", ebj: "", mal: "", cdj: "", raw: "", engtl: "")
        self.originalLanguage = ""
        self.lastVolume = ""
        self.lastChapter = ""
        self.publicationDemographic = Demographic.shounen
        self.status = Status.ongoing
        self.year = 0
        self.contentRating = Rating.safe
        self.tags = []
        self.state = ""
        self.chapterNumbersResetOnNewVolume = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.version = 0
        self.availableTranslatedLanguages = []
        self.latestUploadedChapter = nil
        self.author = []
        self.artist = []
        self.cover = nil
        self.relatedManga = nil
    }
    
    /// Creates a ``Manga`` instance initialized by the given values.
    public init(id: UUID, title: [String : String], altTitles: [[String : String]], description: [[String : String]], isLocked: Bool, links: MangaLink, originalLanguage: String, lastVolume: String?, lastChapter: String?, publicationDemographic: Demographic?, status: Status, year: Int?, contentRating: Rating, tags: [Tag], state: String, chapterNumbersResetOnNewVolume: Bool, createdAt: Date, updatedAt: Date, version: Int, availableTranslatedLanguages: [String], latestUploadedChapter: UUID?, author: [Author]?, artist: [Author]?, cover: Cover?, relatedManga: [RelatedManga]?) {
        self.id = id
        self.title = title
        self.altTitles = altTitles
        self.description = description
        self.isLocked = isLocked
        self.links = links
        self.originalLanguage = originalLanguage
        self.lastVolume = lastVolume
        self.lastChapter = lastChapter
        self.publicationDemographic = publicationDemographic
        self.status = status
        self.year = year
        self.contentRating = contentRating
        self.tags = tags
        self.state = state
        self.chapterNumbersResetOnNewVolume = chapterNumbersResetOnNewVolume
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.version = version
        self.availableTranslatedLanguages = availableTranslatedLanguages
        self.latestUploadedChapter = latestUploadedChapter
        self.author = author
        self.artist = artist
        self.cover = cover
        self.relatedManga = relatedManga
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)

        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.title = try attributesContainer.decode([String: String].self, forKey: .title)
        self.altTitles = try attributesContainer.decode([[String: String]].self, forKey: .altTitles)
        self.description = try attributesContainer.decode([[String: String]].self, forKey: .description)
        self.isLocked = try attributesContainer.decode(Bool.self, forKey: .isLocked)
        self.links = try attributesContainer.decode(MangaLink.self, forKey: .links)
        self.originalLanguage = try attributesContainer.decode(String.self, forKey: .originalLanguage)
        self.lastVolume = try attributesContainer.decode(String.self, forKey: .lastVolume)
        self.lastChapter = try attributesContainer.decode(String.self, forKey: .lastChapter)
        self.publicationDemographic = try attributesContainer.decodeIfPresent(Demographic.self, forKey: .publicationDemographic)
        self.status = try attributesContainer.decode(Status.self, forKey: .status)
        self.year = try attributesContainer.decodeIfPresent(Int.self, forKey: .year)
        self.contentRating = try attributesContainer.decode(Rating.self, forKey: .contentRating)
        self.tags = try attributesContainer.decode([Tag].self, forKey: .tags)
        self.state = try attributesContainer.decode(String.self, forKey: .state)
        self.chapterNumbersResetOnNewVolume = try attributesContainer.decode(Bool.self, forKey: .chapterNumbersResetOnNewVolume)
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.createdAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .createdAt))!
        self.updatedAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .updatedAt))!
        
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        self.availableTranslatedLanguages = try attributesContainer.decode([String].self, forKey: .availableTranslatedLanguages)
        self.latestUploadedChapter = try attributesContainer.decodeIfPresent(UUID.self, forKey: .latestUploadedChapter)
        
        var authors: [Author] = []
        var artists: [Author] = []
        var coverArt: Cover?
        var relatedManga: [RelatedManga] = []
        
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
                }
            }
        }

        self.author = authors
        self.artist = artists
        self.cover = coverArt
        self.relatedManga = relatedManga
    }
}

/// An object containing the information of a related manga.
///
/// ### See
/// ``MangaRelated``
public struct RelatedManga: Decodable, Identifiable, Sendable {
    /// A unique id assigned to a manga.
    public let id: UUID
    
    /// The type of this object.
    let type: String
    
    /// A description of how this manga is related.
    let related: String
    
    private enum CodingKeys: CodingKey {
        case id
        case type
        case related
    }
    
    /// Creates a ``RelatedManga`` instance initialized with placeholder values.
    public init() {
        self.id = UUID()
        self.type = ""
        self.related = ""
    }
    
    /// Creates a ``RelatedManga`` instance initialized by the given values.
    public init(id: UUID, type: String, related: String) {
        self.id = id
        self.type = type
        self.related = related
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
        self.related = try container.decode(String.self, forKey: .related)
    }
}

