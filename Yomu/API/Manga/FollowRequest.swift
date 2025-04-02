//
//  FollowRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-31.
//

import Foundation

///
struct Follow {
    let manga: UUID
    
    init(manga: UUID) {
        self.manga = manga
    }
}

extension Follow: MangaDexAPIRequest {
    typealias ModelType = Response
    
    func decode(_ data: Data) throws -> Response {
        return try JSONDecoder().decode(Response.self, from: data)
    }
    
    func execute() async throws -> Response {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga/\(manga.uuidString.lowercased())/follow"
        
        return try await authenticatedGet(from: components.url!)
    }
}

struct Unfollow {
    let manga: UUID
    
    init(manga: UUID) {
        self.manga = manga
    }
}

extension Unfollow: MangaDexAPIRequest {
    typealias ModelType = Response
    
    func decode(_ data: Data) throws -> Response {
        return try JSONDecoder().decode(Response.self, from: data)
    }
    
    func execute() async throws -> Response {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga/\(manga.uuidString.lowercased())/follow"
        
        return try await authenticatedDelete(at: components.url!)
    }
}
