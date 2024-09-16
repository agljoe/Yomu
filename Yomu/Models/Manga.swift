//
//  Manga.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation

//TODO: decode dates as Date? rather than String
struct MangaEntity: Decodable, Identifiable {
    let id: UUID
    let related: String?
    let title: [String: String]
    let altTitles: [[String: String]]
    let description: [String: String]
    let isLocked: Bool
    let links: MangaLink
    let originalLanguage: String
    let lastVolume: String?
    let lastChapter: String?
    let publicationDemographic: Demographic?
    let status: Status
    let year: Int?
    let contentRating: Rating
    let tags: [Tag]
    let state: String
    let chapterNumbersResetOnNewVolume: Bool
    let createdAt: String
    let updatedAt: String
    let version: Int
    let availableTranslatedLanguages: [String]
    let latestUploadedChapter: UUID? // same as id in Chapter structt
    let author: [Author]?
    let artist: [Artist]?
    let cover: Cover?
    let relatedManga: [RelatedManga]?
    
    enum CodingKeys: CodingKey {
        case id, related, attributes, relationships
    }
    
    enum AttributeCodingKeys: CodingKey {
        case title, altTitles, description, isLocked, links, originalLanguage, lastVolume, lastChapter, publicationDemographic, status, year, contentRating, tags, state, chapterNumbersResetOnNewVolume, createdAt, updatedAt, version, availableTranslatedLanguages, latestUploadedChapter
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.related = try container.decodeIfPresent(String.self, forKey: .related)

        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.title = try attributesContainer.decode([String: String].self, forKey: .title)
        self.altTitles = try attributesContainer.decode([[String: String]].self, forKey: .altTitles)
        self.description = try attributesContainer.decode([String: String].self, forKey: .description)
        
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
        
        self.createdAt = try attributesContainer.decode(String.self, forKey: .createdAt)
        self.updatedAt = try attributesContainer.decode(String.self, forKey: .updatedAt)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        
        self.availableTranslatedLanguages = try attributesContainer.decode([String].self, forKey: .availableTranslatedLanguages)
        
        self.latestUploadedChapter = try attributesContainer.decodeIfPresent(UUID.self, forKey: .latestUploadedChapter)
        
        var authors: [Author] = []
        var artists: [Artist] = []
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

public struct Manga: Decodable, Identifiable, Sendable {
    public let id: UUID
    let related: String?
    let title: [String: String]
    let altTitles: [[String: String]]
    let description: [String: String]
    let isLocked: Bool
    let links: MangaLink
    let originalLanguage: String
    let lastVolume: String?
    let lastChapter: String?
    let publicationDemographic: Demographic?
    let status: Status
    let year: Int?
    let contentRating: Rating
    let tags: [Tag]
    let state: String
    let chapterNumbersResetOnNewVolume: Bool
    let createdAt: String
    let updatedAt: String
    let version: Int
    let availableTranslatedLanguages: [String]
    let latestUploadedChapter: UUID?
    let author: [Author]?
    let artist: [Artist]?
    let cover: Cover?
    let relatedManga: [RelatedManga]?
    
    init() {
        self.id = UUID()
        self.related = ""
        self.title = ["": ""]
        self.altTitles = [["": ""]]
        self.description = ["": ""]
        self.isLocked = false
        self.links = MangaLink(al: "", ap: "", bw: "", mu: "", nu: "", kt: "", amz: "", ebj: "", mal: "", cdj: "", raw: "", engtl: "")
        self.originalLanguage = ""
        self.lastVolume = ""
        self.lastChapter = ""
        self.publicationDemographic = Demographic.shounen
        self.status = Status.ongoing
        self.year = 0
        self.contentRating = Rating.safe
        self.tags = [Tag]()
        self.state = ""
        self.chapterNumbersResetOnNewVolume = false
        self.createdAt = ""
        self.updatedAt = ""
        self.version = 0
        self.availableTranslatedLanguages = [String]()
        self.latestUploadedChapter = nil
        self.author = [Author]()
        self.artist = [Artist]()
        self.cover = nil
        self.relatedManga = nil
    }
    
    init(id: UUID, related: String?, title: [String : String], altTitles: [[String : String]], description: [String : String], isLocked: Bool, links: MangaLink, originalLanguage: String, lastVolume: String?, lastChapter: String?, publicationDemographic: Demographic?, status: Status, year: Int?, contentRating: Rating, tags: [Tag], state: String, chapterNumbersResetOnNewVolume: Bool, createdAt: String, updatedAt: String, version: Int, availableTranslatedLanguages: [String], latestUploadedChapter: UUID?, author: [Author]?, artist: [Artist]?, cover: Cover?, relatedManga: [RelatedManga]?) {
        self.id = id
        self.related = related
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
    
    init(from entity: MangaEntity) {
        self.id = entity.id
        self.related = entity.related
        self.title = entity.title
        self.altTitles = entity.altTitles
        self.description = entity.description
        self.isLocked = entity.isLocked
        self.links = entity.links
        self.originalLanguage = entity.originalLanguage
        self.lastVolume = entity.lastVolume
        self.lastChapter = entity.lastChapter
        self.publicationDemographic = entity.publicationDemographic
        self.status = entity.status
        self.year = entity.year
        self.contentRating = entity.contentRating
        self.tags = entity.tags
        self.state = entity.state
        self.chapterNumbersResetOnNewVolume = entity.chapterNumbersResetOnNewVolume
        self.createdAt = entity.createdAt
        self.updatedAt = entity.updatedAt
        self.version = entity.version
        self.availableTranslatedLanguages = entity.availableTranslatedLanguages
        self.latestUploadedChapter = entity.latestUploadedChapter
        self.author = entity.author
        self.artist = entity.artist
        self.cover = entity.cover
        self.relatedManga = entity.relatedManga
    }
    
    public init(from decoder: any Decoder) throws {
        let entity = try MangaEntity(from: decoder)
        self.init(from: entity)
    }
    
}

struct RelatedManga: Decodable {
    let id: UUID
    let type: String
    let related: String
}

