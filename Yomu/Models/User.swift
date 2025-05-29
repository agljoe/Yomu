//
//  User.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-04.
//

import Foundation
import SwiftData

/// A MangaDex user.
///
/// The primary use of user types will be to display the uploader of a chapter.
///
/// ### See Also
/// [MangaDex Api Documentation](https://api.mangadex.org/docs/redoc.html#tag/User/operation/get-user-id)
struct User: Identifiable, Equatable, Hashable, Decodable, Sendable {
    /// The UUID of this user.
    let id: UUID
    
    /// The name of this user.
    ///
    /// This value should be unchangable.
    let username: String
    
    /// The roles this user has in their respective scanlation group, or as a MangaDex staff.
    let roles: [String]
    
    /// The version of this user.
    let version: Int
    
    let relationships: [UserRealtionship]
    
    /// The base coding keys for this struct.
    private enum CodingKeys: CodingKey {
        case id, attributes, relationships
    }
    
    /// The nested coding keys found through the attributes keypath.
    private enum AttributeCodingKeys: CodingKey {
        case username, roles, version
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: the decoder to read data from.
    ///
    /// - Returns: a newly created User from the given decoder.
    ///
    /// - Throws: a ` DeodingError` if a User cannot be initialized by the given decoder.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.username = try attributesContainer.decode(String.self, forKey: .username)
        self.roles = try attributesContainer.decode([String].self, forKey: .roles)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        
        self.relationships = try container.decodeIfPresent([UserRealtionship].self, forKey: .relationships) ?? []
    }
}

extension User {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

struct UserRealtionship: Decodable, Equatable, Hashable, Sendable {
    let id: UUID
    let type: String
    
    static func == (lhs: UserRealtionship, rhs: UserRealtionship) -> Bool { lhs.id == rhs.id }
}

/// A User that is stored in a user's local SwiftData library context.
@Model
class StoredUser {
    #Unique<StoredUser>([\.id])
    #Index<StoredUser>([\.id], [\.username])
    
    /// The UUID of this user.
    @Attribute(.unique) private(set) var id: UUID
    
    /// The name of this user.
    ///
    /// This value should be immutable..
    var username: String
    
    /// The roles this user has in their respective scanlation group, or as a MangaDex staff.
    var roles: [String]
    
    /// The version of this user.
    var version: Int
    
    
    /// Creates a new StoredUser instance from the given values..
    ///
    /// - Parameters
    ///     - id: the UUID of a user.
    ///     - username: the name of a user.
    ///     - roles: titles given to this user as either part of a scanlation group or as MangaDex staff.
    ///     - version: the version of a user.
    ///
    /// - Returns: a newly created StoredUser.
    init(id: UUID, username: String, roles: [String], version: Int) {
        self.id = id
        self.username = username
        self.roles = roles
        self.version = version
    }
    
    /// Creates a new StoredUser instance from the specified User.
    ///
    /// - Parameter user: the user to create a stored instance of.
    ///
    /// - Returns: a newly created StoredUser.
    convenience init(from user: User) {
        self.init(
            id: user.id,
            username: user.username,
            roles: user.roles,
            version: user.version
        )
    }
}

extension StoredUser: Equatable {
    static func == (lhs: StoredUser, rhs: StoredUser) -> Bool {
        lhs.id == rhs.id && lhs.version == rhs.version
    }
}
