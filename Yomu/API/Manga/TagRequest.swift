//
//  TagRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-01.
//

import Foundation

/// Requests a list of all available manga tags.
struct TagListRequest: MangaDexAPIRequest {
    typealias ModelType = ([Tag], Int, Int)
    
    func decode(_ data: Data) throws -> ([Tag], Int, Int) {
        let result = try JSONDecoder().decode(Wrapper<[Tag]>.self, from: data)
        return (result.data, result.offset ?? 0, result.total ?? 0)
    }
    
    func execute() async throws -> ([Tag], Int, Int) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga/tag"
        return try await get(from: components.url!)
    }
}


