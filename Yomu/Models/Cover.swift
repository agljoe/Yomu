//
//  Cover.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-24.
//

import Foundation

public struct Cover: Decodable, Identifiable, Sendable {
    public let id: UUID
    let volume: String
    let fileName: String
    let description: String
    let locale: String
    let version: Int
    let createdAt: String
    let updatedAt: String
//    let relationships: [Relationship]
    
    enum CodingKeys: CodingKey {
        case id, attributes
//        case relationships
    }
    
    enum AttributeCodingKeys: CodingKey {
        case volume
        case fileName
        case description
        case locale
        case version
        case createdAt
        case updatedAt
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.volume = try attributesContainer.decode(String.self, forKey: .volume)
        self.fileName = try attributesContainer.decode(String.self, forKey: .fileName)
        self.description = try attributesContainer.decode(String.self, forKey: .description)
        self.locale = try attributesContainer.decode(String.self, forKey: .locale)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        self.createdAt = try attributesContainer.decode(String.self, forKey: .createdAt)
        self.updatedAt = try attributesContainer.decode(String.self, forKey: .updatedAt)
        
//        self.relationships = try container.decode([Relationship].self, forKey: .relationships)
    }
}
