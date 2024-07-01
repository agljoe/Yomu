//
//  Chapter.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-11.
//

import Foundation


public struct Chapter: Decodable, Identifiable, Sendable {
    public let id: UUID
    let type: String
    let title: String
    let volume: String
    let chapter: String
    let pages: Int
    let translatedLanguage: String
    let uploader: UUID
    let externalUrl: String
    let version: Int
    let createdAt: String
    let updatedAt: String
    let publishAt: String
    let readableAt: String
//    let relationships: [Relationship]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    enum DataCodingKeys: String, CodingKey {
        case id
        case type
        case attributes
//        case relationships
    }
    
    enum AttributeCodingKeys: String, CodingKey {
        case title
        case volume
        case chapter
        case pages
        case translatedLanguage
        case uploader
        case externalUrl
        case version
        case createdAt
        case updatedAt
        case publishAt
        case readableAt
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let dataContainer = try container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        self.id = try dataContainer.decode(UUID.self, forKey: .id)
        self.type = try dataContainer.decode(String.self, forKey: .type)
        
        let attributesContainer = try dataContainer.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.title = try attributesContainer.decode(String.self, forKey: .title)
        self.volume = try attributesContainer.decode(String.self, forKey: .volume)
        self.chapter = try attributesContainer.decode(String.self, forKey: .chapter)
        self.pages = try attributesContainer.decode(Int.self, forKey: .pages)
        self.translatedLanguage = try attributesContainer.decode(String.self, forKey: .translatedLanguage)
        self.uploader = try attributesContainer.decode(UUID.self, forKey: .uploader)
        self.externalUrl = try attributesContainer.decode(String.self, forKey: .externalUrl)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        self.createdAt = try attributesContainer.decode(String.self, forKey: .createdAt)
        self.updatedAt = try attributesContainer.decode(String.self, forKey: .updatedAt)
        self.publishAt = try attributesContainer.decode(String.self, forKey: .publishAt)
        self.readableAt = try attributesContainer.decode(String.self, forKey: .readableAt)
        
//        self.relationships = try dataContainer.decode([Relationship].self, forKey: .relationships)
    }
}

public func getChapter(id: String) async throws -> Chapter {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/chapter/\(id)"

    guard let url = components.url else { throw MDApiError.badRequest }

    let data = try await Request().get(for: url)
    let chapter = try JSONDecoder().decode(Chapter.self, from: data)
    return chapter
}
