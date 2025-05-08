//
//  UserEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-07.
//

import Foundation

/// An entity representing all necessary compontents for fetching a specified user.
struct UserEntity: MangaDexAPIEntity {
    /// The UUID of the user being retrieved.
    var id: UUID
    
    typealias ModelType = User
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/user/\(id.uuidString.lowercased())"
        return components.url!
    }
    
    var requiresAuthentication: Bool { false }
}
