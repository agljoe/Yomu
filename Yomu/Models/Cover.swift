//
//  Cover.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-24.
//

import Foundation

/// The cover of a manga's latest volume.
///
/// > Important:
///     The cover image is found at the ``Cover/fileName`` endpoint.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/Cover)
public struct Cover: Decodable, Equatable, Hashable, Identifiable, Sendable {
    /// A unique id assigned to a cover.
    public let id: UUID
    
    /// The volume this is the cover of.
    let volume: String?
    
    /// A path to a cover image.
    let fileName: String
    
    /// A small text describing a cover.
    let description: String?
    
    /// A time or place a cover is set in.
    let locale: String?
    
    /// A number desctibing the version of a cover.
    let version: Int
    
    /// The date a cover was uploaded to MangaDex.
    let createdAt: Date
    
    /// The date a cover was last modified.
    let updatedAt: Date
    
    /// A collection of objects related to a cover
    ///
    /// Unlike other structures, objects found in a cover's reference expainsion all have the same structure.
    ///  See ``CoverRelationship``.
    let relationships: [CoverRelationship]?
    
    private enum CodingKeys: CodingKey {
        case id, attributes, relationships
    }
    
    private enum AttributeCodingKeys: CodingKey {
        case volume, fileName, description, locale, version, createdAt, updatedAt
    }
    
    /// Creates a ``Cover`` instance initialized with placeholder values.
    public init() {
        self.id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        self.volume = nil
        self.fileName = ""
        self.description = nil
        self.locale = nil
        self.version = 0
        self.createdAt = Date()
        self.updatedAt = Date()
        self.relationships = []
    }
    
    /// Creates a ``Cover`` instance initialized by the given  values.
    public init(id: UUID, volume: String?, fileName: String, description: String?, locale: String?, version: Int, createdAt: Date, updatedAt: Date, relationShips: [CoverRelationship]) {
        self.id = id
        self.volume = volume
        self.fileName = fileName
        self.description = description
        self.locale = locale
        self.version = version
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.relationships = relationShips
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.volume = try attributesContainer.decodeIfPresent(String.self, forKey: .volume)
        self.fileName = try attributesContainer.decode(String.self, forKey: .fileName)
        self.description = try attributesContainer.decodeIfPresent(String.self, forKey: .description)
        self.locale = try attributesContainer.decodeIfPresent(String.self, forKey: .locale)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.createdAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .createdAt))!
        self.updatedAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .updatedAt))!
        
        self.relationships = try container.decodeIfPresent([CoverRelationship].self, forKey: .relationships)
    }
}

/// An object found in the referenece expansion collection of a ``Cover``.
///
/// ### See Also
/// [Reference Expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
public struct CoverRelationship: Decodable, Equatable, Hashable, Identifiable, Sendable {
    /// A unique id.
    ///
    /// >Note:
    /// This UUID is either a user or manga id.
    public let id: UUID
    
    /// The type of this relationship.
    let type: String
    
    private enum CodingKeys: CodingKey {
        case id
        case type
    }
    
    /// Creates a ``CoverRelationship`` instance initialized with placeholder values.
    public init() {
        self.id = UUID()
        self.type = ""
    }
    
    /// Creates a ``CoverRelationship`` instance initialized by the given values.
    public init (id: UUID, type: String) {
        self.id = id
        self.type = type
    }

    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
    }
}
