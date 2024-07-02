//
//  Manga.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation

private struct MangaData: Decodable {
    let data: Manga
    
    enum CodingKeys: CodingKey {
        case data
    }
}

//TODO: decode dates as Date? rather than String
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
    let latestUploadedChapter: UUID? // same as Chapter.id
    let author: [Author]?
    let artist: [Artist]?
    let cover: Cover?
    let relatedManga: [Manga]?
    
    enum CodingKeys: CodingKey {
        case id, related, attributes, relationships
    }
    
    enum AttributeCodingKeys: CodingKey {
        case title, altTitles, description, isLocked, links, originalLanguage, lastVolume, lastChapter, publicationDemographic, status, year, contentRating, tags, state, chapterNumbersResetOnNewVolume, createdAt, updatedAt, version, availableTranslatedLanguages, latestUploadedChapter
    }
    
    enum RelationshipCodingKeys: CodingKey {
        case type
    }
    
    enum RelationshipType: String, Decodable {
        case author
        case artist
        case cover_art
        case manga
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
        var relatedManga: [Manga] = []
        
        var coverArt: [Cover] = []
        
        var typeArray = try container.nestedUnkeyedContainer(forKey: .relationships)
        
        var array = typeArray
        
        while !typeArray.isAtEnd {
            let relationship = try typeArray.nestedContainer(keyedBy: RelationshipCodingKeys.self)
            
            let type = try relationship.decode(RelationshipType.self, forKey: .type)
            
            switch type {
            case .author:
                let author = try array.decode(Author.self)
                authors.append(author)
            case .artist:
                let artist = try array.decode(Artist.self)
                artists.append(artist)
            case .cover_art:
                let cover = try array.decode(Cover.self)
                coverArt.append(cover)
            case .manga:
                let manga = try array.decode(Manga.self)
                relatedManga.append(manga)
            }
        }

        self.author = authors
        self.artist = artists
        self.cover = coverArt.first // weird hacky solution because relationships are forced into a heteronegous array, but only one cover art will ever be present in response json
        self.relatedManga = relatedManga
    }

}

public func getManga(id: String) async throws -> Manga {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/\(id)"
    components.queryItems = [
        URLQueryItem(name: "includes[]", value: "manga"),
//        URLQueryItem(name: "includes[]", value: "cover_art"),
        URLQueryItem(name: "includes[]", value: "artist"),
        URLQueryItem(name: "includes[]", value: "Author")
    ]

    guard let url = components.url else { throw MDApiError.badRequest }

    let data = try await Request().get(for: url)
    let manga = try! JSONDecoder().decode(MangaData.self, from: data)
    print(manga.data)
    return manga.data
}

public func getMangaChapters(id: String) async throws -> [Chapter] {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/\(id)/feed"
    
    guard let url = components.url else { throw MDApiError.badRequest }
    
    let data = try await Request().get(for: url)
    let chapters = try JSONDecoder().decode([Chapter].self, from: data)
    return chapters
}

public func getCover(id: String) async throws -> Cover {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/cover/\(id)"
    
    guard let url = components.url else { throw MDApiError.badRequest }
    
    let data = try await Request().get(for: url)
    let cover = try! JSONDecoder().decode(CoverData.self, from: data)
    print(cover.data)
    
    return cover.data
}
