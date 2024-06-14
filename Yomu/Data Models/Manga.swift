//
//  Manga.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation

public struct Manga: Decodable, Identifiable, Sendable {
    public let id: UUID
    let type: String
    let title: LocalizedLanguage
    let altTitles: [LocalizedLanguage]?
    let description: LocalizedLanguage
    let isLocked: Bool
    let links: MangaLink
    let originalLanguage: String
    let lastVolume: String
    let lastChapter: String?
    let publicationDemographic: Demographic
    let status: Status
    let year: Int
    let contentRating: Rating
    let tags: [Tag]
    let state: String
    let chapterNumbersResetOnNewVolume: Bool
    let createdAt: String
    let updatedAt: String
    let version: Int
    let availableTranslatedLanguages: [String]
    let latestUploadedChapter: UUID // same as Chapter.id
    let relationships: [Relationship]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    enum DataCodingKeys: String, CodingKey {
        case id
        case type
        case attributes
        case relationships
    }
    
    enum AttributeCodingKeys: String, CodingKey {
        case title
        case altTitles
        case description
        case isLocked
        case links
        case originalLanguage
        case lastVolume
        case lastChapter
        case publicationDemographic
        case status
        case year
        case contentRating
        case tags
        case state
        case chapterNumbersResetOnNewVolume
        case createdAt
        case updatedAt
        case version
        case availableTranslatedLanguages
        case latestUploadedChapter
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        self.id = try dataContainer.decode(UUID.self, forKey: .id)
        self.type = try dataContainer.decode(String.self, forKey: .type)
        let attributesContainer = try dataContainer.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.title = try attributesContainer.decode(LocalizedLanguage.self, forKey: .title)
        self.altTitles = try attributesContainer.decode([LocalizedLanguage].self, forKey: .altTitles)
        self.description = try attributesContainer.decode(LocalizedLanguage.self, forKey: .description)
        self.isLocked = try attributesContainer.decode(Bool.self, forKey: .isLocked)
        self.links = try attributesContainer.decode(MangaLink.self, forKey: .links)
        self.originalLanguage = try attributesContainer.decode(String.self, forKey: .originalLanguage)
        self.lastVolume = try attributesContainer.decode(String.self, forKey: .lastVolume)
        self.lastChapter = try attributesContainer.decode(String.self, forKey: .lastChapter)
        self.publicationDemographic = try attributesContainer.decode(Demographic.self, forKey: .publicationDemographic)
        self.status = try attributesContainer.decode(Status.self, forKey: .status)
        self.year = try attributesContainer.decode(Int.self, forKey: .year)
        self.contentRating = try attributesContainer.decode(Rating.self, forKey: .contentRating)
        self.tags = try attributesContainer.decode([Tag].self, forKey: .tags)
        self.state = try attributesContainer.decode(String.self, forKey: .state)
        self.chapterNumbersResetOnNewVolume = try attributesContainer.decode(Bool.self, forKey: .chapterNumbersResetOnNewVolume)
        self.createdAt = try attributesContainer.decode(String.self, forKey: .createdAt)
        self.updatedAt = try attributesContainer.decode(String.self, forKey: .updatedAt)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        self.availableTranslatedLanguages = try attributesContainer.decode([String].self, forKey: .availableTranslatedLanguages)
        self.latestUploadedChapter = try attributesContainer.decode(UUID.self, forKey: .latestUploadedChapter)
        self.relationships = try dataContainer.decode([Relationship].self, forKey: .relationships)
    }

}

struct Tag: Decodable {
    let id: UUID
    let type: String
    let name: LocalizedLanguage
    let relationships: [Relationship]
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case attributes
        case relationships
    }
    
    enum AttributeCodingKeys: CodingKey {
        case name
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
        let nameContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.name = try nameContainer.decode(LocalizedLanguage.self, forKey: .name)
        self.relationships = try container.decode([Relationship].self, forKey: .relationships)
    }
}

public func getManga(id: String) async throws -> Manga {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/\(id)"

    guard let url = components.url else { throw MDApiError.badRequest }

    let data = try await Request().get(for: url)
    let manga = try JSONDecoder().decode(Manga.self, from: data)
    return manga
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
