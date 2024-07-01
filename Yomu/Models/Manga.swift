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

public struct Manga: Decodable, Identifiable, Sendable {
    public let id: UUID
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
    var author: [Author]?
    var artist: [Artist]?
    var relatedManga: [Manga]?
    
    enum CodingKeys: CodingKey {
        case id, attributes, relationships
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
        case manga
        //case cover_art
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)

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
        var mangas: [Manga] = []
        
        var typeArray = try! container.nestedUnkeyedContainer(forKey: .relationships)
        
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
            case .manga:
                let manga = try array.decode(Manga.self)
                mangas.append(manga)
            }
            
            self.author = authors
            self.artist = artists
            self.relatedManga = mangas
        }
//        let relationshipsContainer = try container.superDecoder(forKey: .relationships)
//        
//        self.author = try [Author](from: relationshipsContainer)
//        self.artist = try [Author](from: relationshipsContainer)
//        self.relatedManga = try [Manga](from: relationshipsContainer)
//        let relationships = try container.decode([Data].self, forKey: .relationships)
//        
//        var authors: [Author] = []
//        var artists: [Author] = []
//        var relatedManga: [Manga] = []
//        
//        for relationship in relationships {
//            if let author = try? JSONDecoder().decode(Author.self, from: relationship) {
//                authors.append(author)
//            } else if let artist = try? JSONDecoder().decode(Author.self, from: relationship) {
//                artists.append(artist)
//            } else if let manga = try? JSONDecoder().decode(Manga.self, from: relationship) {
//                relatedManga.append(manga)
//            } else { throw DecodingError.dataCorruptedError(forKey: .relationships, in: container, debugDescription: "Failed to decode refence expansion")}
//        }
//        
//        self.author = authors
//        self.artist = artists
//        self.relatedManga = relatedManga
    }

}

//struct MangaRelationship: Identifiable, Decodable, Sendable {
//    let id: UUID
//    let type: String
//    
//    let name: String?
//    let title: String?
//    let fileName: String?
//    
//    enum CodingKeys: CodingKey {
//        case id, type, attributes
//    }
//     
//    enum AttributeCodingKeys: CodingKey {
//        case name, fileName, title
//    }
//    
//    enum TitleCodingKeys: CodingKey {
//        case en
//    }
//    
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(UUID.self, forKey: .id)
//        
//        self.type = try container.decode(String.self, forKey: .type)
//        
//        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
//        
//        self.name = try attributesContainer.decodeIfPresent(String.self, forKey: .name)
//        self.title = try attributesContainer.decodeIfPresent(String.self, forKey: .title)
//        self.fileName = try attributesContainer.decodeIfPresent(String.self, forKey: .fileName)
//    }
//    
//}


public func getManga(id: String) async throws -> Manga {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/\(id)"
    components.queryItems = [
        URLQueryItem(name: "includes[]", value: "manga"),
        URLQueryItem(name: "includes[]", value: "cover_art"),
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
