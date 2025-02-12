//
//  Author.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-11.
//

import Foundation

/// An author or artist of a manga.
///
///  MangaDex only makes a distinction between authors, and artists with ``Author/type``.
///  The endpoint, and JSON struction is otherwise identical.
///
/// ### See Also
/// [MangaDex Api Documentation](https://api.mangadex.org/docs/redoc.html#tag/Author/operation/get-author-id)
public struct Author: Decodable, Identifiable, Sendable {
    /// A unique id assigned to an author or arist.
    public let id: UUID
    
    /// A string describing the type of an ``Author`` value.
    ///
    /// This distingushes between author and artist.
    let type: String
    
    /// An author or artists full name.
    ///
    /// Artist and author names are romanized.
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
    let realtedManga: [Manga]?
    
    private enum CodingKeys: CodingKey {
        case id, type, attributes, relationships
    }
    
    private enum AttributesCodingKeys: CodingKey {
        case name, imageUrl, biography, twitter, pixiv, melonBook, fanBox, booth, nicoVideo, skeb, fantia, tumblr, youtube, weibo, naver, namicomi, website, createdAt, updatedAt, version
    }
    
    /// Creates an ``Author``instance initialized with placeholder values.
    public init() {
        self.id = UUID()
        self.type = ""
        self.name = ""
        self.imageUrl = nil
        self.biography = ["": ""]
        self.twitter = nil
        self.pixiv = nil
        self.melonBook = nil
        self.fanBox = nil
        self.booth = nil
        self.nicoVideo = nil
        self.skeb = nil
        self.fantia = nil
        self.tumblr = nil
        self.youtube = nil
        self.weibo = nil
        self.naver = nil
        self.namicomi = nil
        self.website = nil
        self.createdAt = Date.now
        self.updatedAt = Date.now
        self.version = 0
        self.realtedManga = [Manga]()
    }
    
    /// Creates an ``Author`` instance initialized by the given values.
    public init(id: UUID, type: String, name: String, imageUrl: String?, biography: [String: String], twitter: String?, pixiv: String?, melonBook: String?, fanBox: String?, booth: String?, nicoVideo: String?, skeb: String?, fania: String?, tumbr: String?, youtube: String?, weibo: String?, naver: String?, namicomi: String?, website: String?, createdAt: Date, updateAt: Date, version: Int, relatedManga: [Manga]) {
        self.id = id
        self.type = type
        self.name = name
        self.imageUrl = imageUrl
        self.biography = biography
        self.twitter = twitter
        self.pixiv = pixiv
        self.melonBook = melonBook
        self.fanBox = fanBox
        self.booth = booth
        self.nicoVideo = nicoVideo
        self.skeb = skeb
        self.fantia = fania
        self.tumblr = tumbr
        self.youtube = youtube
        self.weibo = weibo
        self.naver = naver
        self.namicomi = namicomi
        self.website = website
        self.createdAt = createdAt
        self.updatedAt = updateAt
        self.version = version
        self.realtedManga = relatedManga
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: any Decoder) throws {
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
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.createdAt =  RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .createdAt))!
        self.updatedAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .updatedAt))!
        
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        self.realtedManga = try container.decodeIfPresent([Manga].self, forKey: .relationships)
    }
}
