//
//  ScanlationGroup.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-08-25.
//

import Foundation

struct ScanlationGroup: Identifiable, Decodable {
    let id: UUID
    let name: String
    let locked: Bool
    let website: String?
    let ircServer: String?
    let ircChannel: String?
    let discord: String?
    let contactEmail: String?
    let description: String?
    let twitter: String?
    let mangaUpdates: String?
    let focusedLanguages: [String]
    let official: Bool
    let verified: Bool
    let inactive: Bool
    let exLicensed: Bool?
    let publishDelay: String?
    let createdAt: String
    let updatedAt: String
    let version: Int
    let relationships: [User]?
    
    enum CodingKeys: CodingKey {
        case id, name, attributes, relationships
    }
    
    enum AttributeCodingKeys: CodingKey {
        case name, locked, website, ircServer, ircChannel, discord, contactEmail, description, twitter, mangaUpdates, focusedLanguages, official, verified, inactive, exLisensed, publishDelay, createdAt, updatedAt, version
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        
        self.name = try attributesContainer.decode(String.self, forKey: .name)
        
        self.locked = try attributesContainer.decode(Bool.self, forKey: .locked)
        self.website = try attributesContainer.decodeIfPresent(String.self, forKey: .website)
        
        self.ircServer = try attributesContainer.decodeIfPresent(String.self, forKey: .ircServer)
        self.ircChannel = try attributesContainer.decodeIfPresent(String.self, forKey: .ircChannel)
        
        self.discord = try attributesContainer.decodeIfPresent(String.self, forKey: .discord)
        self.contactEmail = try attributesContainer.decodeIfPresent(String.self, forKey: .contactEmail)
        
        self.description = try attributesContainer.decodeIfPresent(String.self, forKey: .description)
        
        self.twitter = try attributesContainer.decodeIfPresent(String.self, forKey: .twitter)
        
        self.mangaUpdates = try attributesContainer.decodeIfPresent(String.self, forKey: .mangaUpdates)
        
        self.focusedLanguages = try attributesContainer.decode([String].self, forKey: .focusedLanguages)
        
        self.official = try attributesContainer.decode(Bool.self, forKey: .official)
        self.verified = try attributesContainer.decode(Bool.self, forKey: .verified)
        self.inactive = try attributesContainer.decode(Bool.self, forKey: .inactive)
        
        self.exLicensed = try attributesContainer.decodeIfPresent(Bool.self, forKey: .exLisensed)
        
        self.publishDelay = try attributesContainer.decodeIfPresent(String.self, forKey: .publishDelay)
        
        self.createdAt = try attributesContainer.decode(String.self, forKey: .createdAt)
        self.updatedAt = try attributesContainer.decode(String.self, forKey: .updatedAt)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        
        self.relationships = try container.decodeIfPresent([User].self, forKey: .relationships)
    }
    
}
