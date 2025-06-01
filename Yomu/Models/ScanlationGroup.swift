//
//  ScanlationGroup.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-08-25.
//

import Foundation
import SwiftData

/// A group of people who translate manga.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/ScanlationGroup/operation/get-group-id)
struct ScanlationGroup: Identifiable, Equatable, Hashable, Decodable, Sendable {
    /// A unique id assigned to a scanlation group.
    let id: UUID
    
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
    
    /// The base coding keys for this struct.
    private enum CodingKeys: CodingKey {
        case id, name, attributes, relationships
    }
    
    /// The nested coding keys found through the attributes keypath.
    private enum AttributeCodingKeys: CodingKey {
        case name, locked, website, ircServer, ircChannel, discord, contactEmail, description, twitter, mangaUpdates, focusedLanguages, official, verified, inactive, exLisensed, publishDelay, createdAt, updatedAt, version
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: the decoder to read data from.
    ///
    /// - Returns: a newly created ScanlationGroup from the given decoder.
    ///
    /// - Throws: a ` DeodingError` if a ScanlationGroup cannot be initialized by the given decoder.
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
        self.focusedLanguages = try attributesContainer.decodeIfPresent([String].self, forKey: .focusedLanguages)
        self.official = try attributesContainer.decode(Bool.self, forKey: .official)
        self.verified = try attributesContainer.decode(Bool.self, forKey: .verified)
        self.inactive = try attributesContainer.decode(Bool.self, forKey: .inactive)
        self.exLicensed = try attributesContainer.decodeIfPresent(Bool.self, forKey: .exLisensed)
        self.publishDelay = try attributesContainer.decodeIfPresent(String.self, forKey: .publishDelay)
        self.createdAt = try attributesContainer.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try attributesContainer.decode(Date.self, forKey: .updatedAt)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        
        self.relationships = try container.decodeIfPresent([User].self, forKey: .relationships)
    }
}

extension ScanlationGroup {
    static func == (lhs: ScanlationGroup, rhs: ScanlationGroup) -> Bool {
        return lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
}

/// A scanlation group stored in a user's local SwiftData library context.
///
/// - Note: This structure's types are made to match the JSON data structure provided in the MangaDexAPI documentation, where
///         optionals are used to represent values that can be null.
@Model
class StoredScanlationGroup {
    #Unique<StoredScanlationGroup>([\.id], [\.id, \.updatedAt])
    #Index<StoredScanlationGroup>([\.id], [\.name])
    
    /// A unique id assigned to a scanlation group.
    @Attribute(.unique, .preserveValueOnDeletion)
    private(set) var id: UUID
    
    /// The name of a scanlation group.
    var name: String
    
    /// A link to the official website of a scanlation group.
    var website: String?
    
    /// A link to the internet relay chat server of a scanlation group.
    var ircServer: String?
    
    /// A link to an internet relay chat channel of a scanlation group.
    var ircChannel: String?
    
    /// A link to the Discord server of a scanlation group.
    var discord: String?
    
    /// The email adress of a scanlation group.
    var contactEmail: String?
    
    /// The description of a scanlation group.
    var about: String?
    
    /// A link to the Twitter page of a scanlation group.
    var twitter: String?
    
    /// A link to the Manga Updates page of a scanlation group.
    var mangaUpdates: String?
    
    /// A collection of languages a scanlation group translates for.
    var focusedLanguages: [String]?
    
    /// Whether or not a scanlation group is an official source.
    var official: Bool
    
    /// Whether or not a scanlation group is verified by MangaDex.
    var verified: Bool
    
    /// Whether or not a scanlation group is active.
    var inactive: Bool
    
    /// Whether or not a scanlation group is exclusively licensed.
    var exLicensed: Bool?
    
    /// The publish delay of chapters translated by a scanlation group.
    var publishDelay: String?
    
    /// The date this scanlation group was last modified.
    var updatedAt: Date
    
    /// A number describing the version of a scanlation group.
    var version: Int
    
    /// A collection of users in a scanlation group.
    @Relationship(deleteRule: .cascade)
    var relationships: [StoredUser]
    
    
    /// Creates a new StoredScanlationGroup from the given values.
    ///
    /// - Parameters:
    ///     - id: the UUID of a scanlation group.
    ///     - name: the name of a scanlation group.
    ///     - website: a link to the official website of a scanlation group.
    ///     - ircServer: a link to the irc server of a scanlation group.
    ///     - ircChannel: the irc channel of a scanlation group.
    ///     - discord: a link to the discord server of a scanlation group.
    ///     - contactEmail: the email address of a scanlation group.
    ///     - about: a short  description of a scanlation group.
    ///     - twitter: a link to a scanlation group's twitter account.
    ///     - mangaUpdates: a link to a scanlation group's mangaupdates page.
    ///     - focusedLanguages: the translated languages of manga by a scanlation group.
    ///     - official: indicates if this is an a official translation group.
    ///     - verified: indicates if a scanlation group has been verified by MangaDex staff.
    ///     - inactive: indicates if a scanlation group is no longer translating manga.
    ///     - exLicensed: indicates if a scanlation group was a licensed translator.
    ///     - publishDelay: the time before manga uploaded by a scanlation group are available on MangaDex.
    ///     - updatedAt: the last time a scanlation group was updated on MangaDex.
    ///     - version: the version of a scanlation group.
    ///     - relationships: the users who are a part of this scanlation group.
    ///
    /// - Returns: a newly created ScanlationGroup.
    init(id: UUID, name: String, website: String? = nil, ircServer: String? = nil, ircChannel: String? = nil, discord: String? = nil, contactEmail: String? = nil, about: String? = nil, twitter: String? = nil, mangaUpdates: String? = nil, focusedLanguages: [String]? = nil, official: Bool, verified: Bool, inactive: Bool, exLicensed: Bool? = nil, publishDelay: String? = nil, updatedAt: Date, version: Int, relationships: [StoredUser]) {
        self.id = id
        self.name = name
        self.website = website
        self.ircServer = ircServer
        self.ircChannel = ircChannel
        self.discord = discord
        self.contactEmail = contactEmail
        self.about = about
        self.twitter = twitter
        self.mangaUpdates = mangaUpdates
        self.focusedLanguages = focusedLanguages
        self.official = official
        self.verified = verified
        self.inactive = inactive
        self.exLicensed = exLicensed
        self.publishDelay = publishDelay
        self.updatedAt = updatedAt
        self.version = version
        self.relationships = relationships
    }
    
    /// Creates a new StoredScanlationGroup from the given ScanlationGroup.
    ///
    /// - Parameter scanlationGroup: the scanlation group to make a stored instance of.
    ///
    /// - Returns: a newly created ScanlationGroup.
    convenience init(from scanlationGroup: ScanlationGroup) {
        self.init(
            id: scanlationGroup.id,
            name: scanlationGroup.name,
            website: scanlationGroup.website,
            ircServer: scanlationGroup.ircServer,
            ircChannel:  scanlationGroup.ircChannel,
            discord: scanlationGroup.discord,
            contactEmail: scanlationGroup.contactEmail,
            about: scanlationGroup.description,
            twitter: scanlationGroup.twitter,
            mangaUpdates: scanlationGroup.mangaUpdates,
            focusedLanguages: scanlationGroup.focusedLanguages,
            official: scanlationGroup.official,
            verified: scanlationGroup.verified,
            inactive: scanlationGroup.inactive,
            exLicensed: scanlationGroup.exLicensed,
            publishDelay: scanlationGroup.publishDelay,
            updatedAt: scanlationGroup.updatedAt,
            version: scanlationGroup.version,
            relationships: scanlationGroup.relationships?.map({ .init(from: $0) }) ?? []
        )
    }
}

extension StoredScanlationGroup: Equatable {
    static func == (lhs: StoredScanlationGroup, rhs: StoredScanlationGroup) -> Bool {
        return lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
}
