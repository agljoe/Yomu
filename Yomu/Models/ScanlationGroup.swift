//
//  ScanlationGroup.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-08-25.
//

import Foundation

/// A group of people who translate manga.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/ScanlationGroup/operation/get-group-id)
public struct ScanlationGroup: Identifiable, Equatable, Hashable, Decodable, Sendable {
    /// A unique id assigned to a scanlation group.
    public let id: UUID
    
    /// The name of a scanlation group.
    let name: String
    
    /// A link to the official website of a scanlation group.
    let website: String?
    
    /// A link to the internet relay chat server of a scanlation group.
    let ircServer: String?
    
    /// A link to an internet relay chat channel of a scanlation group.
    let ircChannel: String?
    
    /// A link to the Discord server of a scanlation group.
    let discord: String?
    
    /// The email adress of a scanlation group.
    let contactEmail: String?
    
    /// The description of a scanlation group.
    let description: String?
    
    /// A link to the Twitter page of a scanlation group.
    let twitter: String?
    
    /// A link to the Manga Updates page of a scanlation group.
    let mangaUpdates: String?
    
    /// A collection of languages a scanlation group translates for.
    let focusedLanguages: [String]?
    
    /// Whether or not a scanlation group is locked.
    let locked: Bool
    
    /// Whether or not a scanlation group is an official source.
    let official: Bool
    
    /// Whether or not a scanlation group is verified by MangaDex.
    let verified: Bool
    
    /// Whether or not a scanlation group is active.
    let inactive: Bool
    
    /// Whether or not a scanlation group is exclusively licensed.
    let exLicensed: Bool?
    
    /// The publish delay of chapters translated by a scanlation group.
    let publishDelay: String?
    
    /// The date this scanlation group was created.
    let createdAt: Date
    
    /// The date this scanlation group was last modified.
    let updatedAt: Date
    
    /// A number describing the version of a scanlation group.
    let version: Int
    
    /// A collection of users in a scanlation group.
    let relationships: [User]?
    
   private enum CodingKeys: CodingKey {
        case id, name, attributes, relationships
    }
    
    private enum AttributeCodingKeys: CodingKey {
        case name, locked, website, ircServer, ircChannel, discord, contactEmail, description, twitter, mangaUpdates, focusedLanguages, official, verified, inactive, exLisensed, publishDelay, createdAt, updatedAt, version
    }
    
    /// Creates a ``ScanlationGroup`` instance initialized with placeholder values.
    public init() {
        self.id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        self.name = ""
        self.locked = false
        self.website = nil
        self.ircServer = nil
        self.ircChannel = nil
        self.discord = nil
        self.contactEmail = nil
        self.description = nil
        self.twitter = nil
        self.mangaUpdates = nil
        self.focusedLanguages = nil
        self.official = false
        self.verified = false
        self.inactive = false
        self.exLicensed = false
        self.publishDelay = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.version = 0
        self.relationships = nil
    }
    
    /// Creates a ``ScanlationGroup`` instance initialized by the given values.
    public init(id: UUID, name: String, locked: Bool, webiste: String?, ircServer: String?, ircChannel: String?, discord: String?, contactEmail: String?, description: String?, twitter: String?, mangaUpdates: String?, focusedLanuage: [String]?, official: Bool, verified: Bool, inactive: Bool, exLicensed: Bool, publishDelay: String?, createdAt: Date, updatedAt: Date, version: Int, relationships: [User]?) {
        self.id = id
        self.name = name
        self.locked = locked
        self.website = webiste
        self.ircServer = ircServer
        self.ircChannel = ircChannel
        self.discord = discord
        self.contactEmail = contactEmail
        self.description = description
        self.twitter = twitter
        self.mangaUpdates = mangaUpdates
        self.focusedLanguages = focusedLanuage
        self.official = official
        self.verified = verified
        self.inactive = inactive
        self.exLicensed = exLicensed
        self.publishDelay = publishDelay
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.version = version
        self.relationships = relationships
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: any Decoder) throws {
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
        self.focusedLanguages = try attributesContainer.decodeIfPresent([String].self, forKey: .focusedLanguages)
        self.official = try attributesContainer.decode(Bool.self, forKey: .official)
        self.verified = try attributesContainer.decode(Bool.self, forKey: .verified)
        self.inactive = try attributesContainer.decode(Bool.self, forKey: .inactive)
        self.exLicensed = try attributesContainer.decodeIfPresent(Bool.self, forKey: .exLisensed)
        self.publishDelay = try attributesContainer.decodeIfPresent(String.self, forKey: .publishDelay)
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.createdAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .createdAt))!
        self.updatedAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .updatedAt))!
        
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        
        self.relationships = try container.decodeIfPresent([User].self, forKey: .relationships)
    }
}
