//
//  Cover.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-24.
//

import Foundation
import SwiftData

/// The cover of a manga's latest volume.
///
/// - Important: The cover image is found at the ``Cover/fileName`` endpoint.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/Cover)
struct Cover: Decodable, Equatable, Hashable, Identifiable, Sendable {
    /// A unique id assigned to a cover.
    let id: UUID
    
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
    
    /// Creates a new instance by decoding from the given decoder.
    init(from decoder: any Decoder) throws {
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
        RFC3339DateFormatter.timeZone = TimeZone.current
        self.createdAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .createdAt))!
        self.updatedAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .updatedAt))!
        
        self.relationships = try container.decodeIfPresent([CoverRelationship].self, forKey: .relationships)
    }
}

extension Cover {
    static func == (lhs: Cover, rhs: Cover) -> Bool {
        return lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
}

/// An object found in the referenece expansion collection of a ``Cover``.
///
/// ### See Also
/// [Reference Expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
struct CoverRelationship: Decodable, Equatable, Hashable, Identifiable, Sendable {
    /// A unique id.
    ///
    /// - Note: This is the UUID of a user of manga.
    let id: UUID
    
    /// The type of this relationship.
    let type: String
    
    private enum CodingKeys: CodingKey {
        case id, type
    }
    
    /// Creates a new instance by decoding from the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
    }
}

extension CoverRelationship {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

@Model
class StoredCover {
    /// A unique id assigned to a cover.
    @Attribute(.unique) private(set) var id: UUID
    
    /// The volume this is the cover of.
    var volume: String?
    
    /// A path to a cover image.
    var fileName: String
    
    /// A small text describing a cover.
    var altText: String?
    
    /// A time or place a cover is set in.
    var locale: String?
    
    /// A number desctibing the version of a cover.
    var version: Int
    
    /// The date a cover was uploaded to MangaDex.
    var createdAt: Date
    
    /// The date a cover was last modified.
    var updatedAt: Date
    
    init(from cover: Cover) {
        self.id = cover.id
        self.volume = cover.volume
        self.fileName = cover.fileName
        self.altText = cover.description
        self.locale = cover.locale
        self.version = cover.version
        self.createdAt = cover.createdAt
        self.updatedAt = cover.updatedAt
    }
}
