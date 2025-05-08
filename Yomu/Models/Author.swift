//
//  Author.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-11.
//

import Foundation
import SwiftData

/// An author or artist of a manga.
///
///  MangaDex only makes a distinction between authors, and artists with ``Author/type``.
///  The endpoint, and JSON struction is otherwise identical.
///
/// - Note: This structure's types are made to match the JSON data structure provided in the MangaDexAPI documentation, where
///          optionals are used to represent values that can be null.
///
/// ### See Also
/// [MangaDex Api Documentation](https://api.mangadex.org/docs/redoc.html#tag/Author/operation/get-author-id)
struct Author: Decodable, Equatable, Hashable, Identifiable, Sendable {
    /// A unique id assigned to an author or arist.
    let id: UUID
    
    /// A string describing the type of an ``Author`` value.
    ///
    /// This distingushes between author and artist.
    let type: String
    
    /// An author or artists full name.
    ///
    /// Artist and author names given in romanji (romanized Japanese).
    let name: String
    
    /// An image of the author or artist.
    ///
    /// MangaDex currently does not support profile pictures, so the value may not exist.
    let imageUrl: String?
    
    /// A brief description of an author or artist.
    ///
    /// An author or artist's biography may not be avialable in all languages.
    let biography: [String: String]
    
    /// A link to an author or artist's Twitter page.
    let twitter: String?
    
    /// A link to an author or artist's pixiv page.
    let pixiv: String?
    
    /// A link to an author or artist's Melonbooks page.
    let melonBook: String?
    
    /// A link to an author or artist's pixivFANBOX page.
    let fanBox: String?
    
    /// A link to an author or artist's BOOTH page.
    let booth: String?
    
    /// A link to an author or artist's Niconico channel.
    let nicoVideo: String?
    
    /// A link to an author or artist's Skeb page.
    let skeb: String?
    
    /// A link to an author or artist's Fantia page.
    let fantia: String?
    
    /// A link to an author or artist's Tumblr page.
    let tumblr: String?
    
    /// A link to an author or artist's YouTube channel.
    let youtube: String?
    
    /// A link to an author or artist's Weibo page.
    let weibo: String?
    
    /// A link to an author or artist's Naver page.
    let naver: String?
    
    /// A link to an author or artist's NamiComi page.
    let namicomi: String?
    
    /// A link to an author or artist's personal website.
    let website: String?
    
    /// The date an author or artist's page was uploaded to MangaDex.
    let createdAt: Date
    
    /// The date an author or artist's page was last modified.
    let updatedAt: Date
    
    /// A number describing the version of this author or artist.
    let version: Int
    
    /// An array of manga by this author or artist.
    let relatedManga: [CompactManga]?
    
    /// The base coding keys for this struct.
    private enum CodingKeys: CodingKey {
        case id, type, attributes, relationships
    }
    
    /// The nested coding keys found through the attributes keypath.
    private enum AttributesCodingKeys: CodingKey {
        case name, imageUrl, biography, twitter, pixiv, melonBook, fanBox, booth, nicoVideo, skeb, fantia, tumblr, youtube, weibo, naver, namicomi, website, createdAt, updatedAt, version
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: the decoder to read data from.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
        self.name = try attributesContainer.decode(String.self, forKey: .name)
        self.imageUrl = try attributesContainer.decodeIfPresent(String.self, forKey: .imageUrl)
        self.biography = try attributesContainer.decode([String: String].self, forKey: .biography)
        self.twitter = try attributesContainer.decodeIfPresent(String.self, forKey: .twitter)
        self.pixiv = try attributesContainer.decodeIfPresent(String.self, forKey: .pixiv)
        self.melonBook = try attributesContainer.decodeIfPresent(String.self, forKey: .melonBook)
        self.fanBox = try attributesContainer.decodeIfPresent(String.self, forKey: .fanBox)
        self.booth = try attributesContainer.decodeIfPresent(String.self, forKey: .booth)
        self.nicoVideo = try attributesContainer.decodeIfPresent(String.self, forKey: .nicoVideo)
        self.skeb = try attributesContainer.decodeIfPresent(String.self, forKey: .skeb)
        self.fantia = try attributesContainer.decodeIfPresent(String.self, forKey: .fantia)
        self.tumblr = try attributesContainer.decodeIfPresent(String.self, forKey: .tumblr)
        self.youtube = try attributesContainer.decodeIfPresent(String.self, forKey: .youtube)
        self.weibo = try attributesContainer.decodeIfPresent(String.self, forKey: .weibo)
        self.naver = try attributesContainer.decodeIfPresent(String.self, forKey: .naver)
        self.namicomi = try attributesContainer.decodeIfPresent(String.self, forKey: .namicomi)
        self.website = try attributesContainer.decodeIfPresent(String.self, forKey: .website)
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone.current
        self.createdAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .createdAt))!
        self.updatedAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .updatedAt))!
        
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        
        var manga: [CompactManga?] = []
        
        do {
            let relationships = try container.decodeIfPresent([AuthorRelationship].self, forKey: .relationships)
            for relationship in relationships ?? [AuthorRelationship]() {
                switch relationship { case .manga(let relatedManga): manga.append(relatedManga) }
            }
        }
        
        self.relatedManga = manga.compactMap({ $0 })
    }
}

extension Author {
    static func == (lhs: Author, rhs: Author) -> Bool {
        return lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
}

/// A Manga that does not include any relationships.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/Manga/operation/get-manga-id)
struct CompactManga: Decodable, Equatable, Hashable, Identifiable, Sendable {
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
    
    /// The base coding keys for this struct.
    private enum CodingKeys: CodingKey {
        case id, attributes
    }
    
    /// The nested coding keys found through the attributes keypath.
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
    }
}

extension CompactManga {
    static func == (lhs: CompactManga, rhs: CompactManga) -> Bool {
        return lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
}

/// An Author or Artist that is stored in a user's local SwiftData library context.
///
/// - Note: This structure's types are made to match the JSON data structure provided in the MangaDexAPI documentation, where
///         optionals are used to represent values that can be null.
@Model
class StoredAuthor {
    /// A unique id assigned to an author or arist.
    @Attribute(.unique) private(set) var id: UUID
    
    /// A string describing the type of an ``Author`` value.
    ///
    /// This distingushes between author and artist.
    var type: String
    
    /// An author or artists full name.
    ///
    /// Artist and author names given in romanji (romanized Japanese).
    var name: String
    
    /// An image of the author or artist.
    ///
    /// MangaDex currently does not support profile pictures, so the value may not exist.
    var imageUrl: String?
    
    /// A brief description of an author or artist.
    ///
    /// An author or artist's biography may not be avialable in all languages.
    var biography: [String: String]
    
    /// A link to an author or artist's Twitter page.
    var twitter: String?
    
    /// A link to an author or artist's pixiv page.
    var pixiv: String?
    
    /// A link to an author or artist's Melonbooks page.
    var melonBook: String?
    
    /// A link to an author or artist's pixivFANBOX page.
    var fanBox: String?
    
    /// A link to an author or artist's BOOTH page.
    var booth: String?
    
    /// A link to an author or artist's Niconico channel.
    var nicoVideo: String?
    
    /// A link to an author or artist's Skeb page.
    var skeb: String?
    
    /// A link to an author or artist's Fantia page.
    var fantia: String?
    
    /// A link to an author or artist's Tumblr page.
    var tumblr: String?
    
    /// A link to an author or artist's YouTube channel.
    var youtube: String?
    
    /// A link to an author or artist's Weibo page.
    var weibo: String?
    
    /// A link to an author or artist's Naver page.
    var naver: String?
    
    /// A link to an author or artist's NamiComi page.
    var namicomi: String?
    
    /// A link to an author or artist's personal website.
    var website: String?
    
    /// The date an author or artist's page was uploaded to MangaDex.
    var createdAt: Date
    
    /// The date an author or artist's page was last modified.
    var updatedAt: Date
    
    /// A number describing the version of this author or artist.
    var version: Int
    
    /// An array of manga by this author or artist.
    @Relationship(inverse: \StoredManga.author)
    @Relationship(inverse: \StoredManga.artist)
    var relatedManga: [StoredManga]? = []
    
    /// Creates a new StoredAuthor instance from the specified Author.
    ///
    /// - Parameter author: The author or artist to create a stored instance of.
    init(from author: Author) {
        self.id = author.id
        self.type = author.type
        self.name = author.name
        self.imageUrl = author.imageUrl
        self.biography = author.biography
        self.twitter = author.twitter
        self.pixiv = author.pixiv
        self.melonBook = author.melonBook
        self.fanBox = author.fanBox
        self.booth = author.booth
        self.nicoVideo = author.nicoVideo
        self.skeb = author.skeb
        self.fantia = author.fantia
        self.tumblr = author.tumblr
        self.youtube = author.youtube
        self.weibo = author.weibo
        self.naver = author.naver
        self.namicomi = author.namicomi
        self.website = author.website
        self.createdAt = author.createdAt
        self.updatedAt = author.updatedAt
        self.version = author.version
        //self.relatedManga = author.relatedManga?.map({ .init(from: $0) })
    }
}

extension StoredAuthor: Equatable {
    static func == (lhs: StoredAuthor, rhs: StoredAuthor) -> Bool {
        return lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
    
    static func += (lhs: inout StoredAuthor, rhs: [Manga]) {
        lhs.relatedManga?.append(contentsOf: rhs.map({ .init(from: $0) }))
    }
}
