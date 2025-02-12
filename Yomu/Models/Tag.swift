//
//  Tag.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-18.
//

import Foundation

/// A tag of a manga.
///
/// Tags describe a manga's format, genre, theme, and content
///
/// ### See Also
/// [MangaDex Api Documentation](https://api.mangadex.org/docs/redoc.html#tag/Manga/operation/get-manga-tag)
public struct Tag: Codable, Identifiable, Sendable {
    public let id: UUID
    let name: String
    let group: String
    
    private enum CodingKeys: CodingKey {
        case id
        case attributes
    }
    
    private enum AttributeCodingKeys: CodingKey {
        case name, group
    }
    
    private enum NameCodingKeys: CodingKey {
        case en
    }
    
    /// Creates a ``Tag`` instance initialized with placeholder values.
    public init() {
        self.id = UUID()
        self.name = ""
        self.group = ""
    }

    /// Creates a ``Tag`` instance initialized by the given values.
    public init(id: UUID = UUID(), name: String = "", group: String = "") {
        self.id = id
        self.name = name
        self.group = group
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributeContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        let nameContainer = try attributeContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        self.name = try nameContainer.decode(String.self, forKey: .en)
        
        self.group = try attributeContainer.decode(String.self, forKey: .group)
    }
    
    /// Encodes a single value with the given encoder.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
        var attributeContainer = container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        var nameContainer = attributeContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        try nameContainer.encode(name, forKey: .en)
        
        try attributeContainer.encode(group, forKey: .group)
        
    }
}


