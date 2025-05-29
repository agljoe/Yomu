//
//  Tag.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-18.
//

import Foundation
import SwiftData

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
    
    /// The base coding keys for this struct.
    private enum CodingKeys: CodingKey {
        case id, attributes
    }
    /// The nested coding keys found through the attributes keypath.
    private enum AttributeCodingKeys: CodingKey {
        case name, group
    }
    
    /// The nested coding key found through the name keypath.
    private enum NameCodingKeys: CodingKey {
        case en
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: the decoder to read data from.
    ///
    /// - Returns: a newly created Tag from the given decoder.
    ///
    /// - Throws: a ` DeodingError` if a Tag cannot be initialized by the given decoder.
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


/// A tag stored in a user's local SwiftData library context.
///
/// - Note: This structure's types are made to match the JSON data structure provided in the MangaDexAPI documentation, where
///         optionals are used to represent values that can be null.
@Model
class StoredTag {
    #Unique<StoredTag>([\.id], [\.name])
    #Index<StoredTag>([\.id], [\.name])
    
    /// A unique id assigned to a tag.
    @Attribute(.unique)
    var id: UUID
    
    /// The name of this tag.
    var name: String
    
    /// The type of content this tag is related to.
    var group: String
    
    /// Creates a new StoredTag instance from the given values.
    ///
    /// - Parameters:
    ///     - id: the UUID of a tag.
    ///     - name: the name of a tag.
    ///     - group: the collection a tag belongs to.
    ///
    /// - Returns: a newly created StoredTag.
    init(id: UUID, name: String, group: String) {
        self.id = id
        self.name = name
        self.group = group
    }
    
    /// Creates a new StoredTag instance from the specified tag.
    ///
    /// - Parameter tag: the tag to create a stored instance of.
    ///
    /// - Returns: a newly created StoredTag.
    convenience init(from tag: Tag) {
        self.init(
            id: tag.id,
            name: tag.name,
            group:tag.group
        )
    }
    
}

