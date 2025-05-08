//
//  ScanlationGroupEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-02.
//

import Foundation

/// Represents the necessary components for fetching a specific scanlation group.
struct ScanlationGroupEntity: MangaDexAPIEntity {
    /// The UUID of the scanlation group being retrieved.
    var id: UUID
    
    typealias ModelType = ScanlationGroup
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/group/\(id.uuidString.lowercased())/"
        components.queryItems = [URLQueryItem(name: "includes[]", value: "leader"), URLQueryItem(name: "includes[]", value: "member")]
        return components.url!
    }
    
    var requiresAuthentication: Bool { false}
    
    
}
