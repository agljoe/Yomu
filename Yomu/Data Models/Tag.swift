//
//  Tag.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-18.
//

import Foundation
//import SwiftData

//@Model
//class FilterTag {
//    var tag: Tag
//    var isIncluded: Bool
//    var isExcluded: Bool
//    
//    init(tag: Tag, isIncluded: Bool, isExcluded: Bool) {
//        self.tag = tag
//        self.isIncluded = isIncluded
//        self.isExcluded = isExcluded
//    }
//}

public struct TagData: Decodable {
    let data: [Tag]
    
    
    enum CodingKeys: CodingKey {
        case data
    }
}

public struct Tag: Codable, Identifiable, Sendable {
    public let id: UUID
    let name: String
    let group: String
    var selection = Selection.none
    
    enum CodingKeys: CodingKey {
        case id
        case attributes
    }
    
    enum AttributeCodingKeys: CodingKey {
        case name
        case group
    }
    
    enum NameCodingKeys: CodingKey {
        case en
    }
    
    enum Selection {
        case none
        case include
        case exclude
    }

    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributeContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        let nameContainer = try attributeContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        self.name = try nameContainer.decode(String.self, forKey: .en)
        
        self.group = try attributeContainer.decode(String.self, forKey: .group)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
        var attributeContainer = container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        var nameContainer = attributeContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        try nameContainer.encode(name, forKey: .en)
        
        try attributeContainer.encode(group, forKey: .group)
        
    }
}

public func getTags() async throws -> [Tag] {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/tag"
    
    guard let url = components.url else { throw MDApiError.badRequest }
    
    let data = try await Request().get(for: url)
    let tags = try JSONDecoder().decode(TagData.self, from: data)
//    print(tags.data)
    
    return tags.data
}


