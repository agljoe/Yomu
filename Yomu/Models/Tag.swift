//
//  Tag.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-18.
//

import Foundation

public struct Tag: Codable, Identifiable, Sendable {
    public let id: UUID
    let name: String
    let group: String
    
    enum CodingKeys: CodingKey {
        case id
        case attributes
    }
    
    enum AttributeCodingKeys: CodingKey {
        case name, group
    }
    
    enum NameCodingKeys: CodingKey {
        case en
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
    
    guard let url = components.url else { throw Request.MDApiError.badRequest }
    
    struct Root: Decodable { let data: [Tag] }
    
    let data = try await Request().get(for: url)
    let tags = try JSONDecoder().decode(Root.self, from: data)
    #if DEBUG
    print(tags.data)
    #endif
    
    return tags.data
}


