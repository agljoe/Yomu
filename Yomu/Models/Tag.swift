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
struct Tag: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// The UUID of a spefic tag.
    ///
    /// For some reason every search filter tag has a unique UUID.
    let id: UUID
    
    /// The name of this tag.
    let name: String
    
    /// The group which this tag belongs to.
    let group: String
    
    private enum CodingKeys: CodingKey {
        case id, attributes
    }
    
    private enum AttributeCodingKeys: CodingKey {
        case name, group
    }
    
    private enum NameCodingKeys: CodingKey {
        case en
    }
    
    /// Creates a new instance by decoding from the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributeContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        let nameContainer = try attributeContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        self.name = try nameContainer.decode(String.self, forKey: .en)
        
        self.group = try attributeContainer.decode(String.self, forKey: .group)
    }
    
    /// Encodes a single value with the given encoder.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
        var attributeContainer = container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        var nameContainer = attributeContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        try nameContainer.encode(name, forKey: .en)
        
        try attributeContainer.encode(group, forKey: .group)
    }
}

extension Tag {
    static func ==(lhs: Tag, rhs: Tag) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}


