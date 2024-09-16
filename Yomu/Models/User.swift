//
//  User.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-04.
//

import Foundation

struct User: Identifiable, Decodable {
    let id: UUID
    let username: String
    let roles: [String]
    let version: Int
    
    enum CodingKeys: CodingKey {
        case id, attributes
    }
    
    enum AttributeCodingKeys: CodingKey {
        case username, roles, version
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.username = try attributesContainer.decode(String.self, forKey: .username)
        self.roles = try attributesContainer.decode([String].self, forKey: .roles)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
    }
}

