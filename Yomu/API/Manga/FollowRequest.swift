//
//  FollowRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-31.
//

import Foundation

struct MangaDexAPIErrorResponse: Decodable {
    let id: String
    let status: Int
    let title: String
    let detail: String?
    let context: String?
}

struct Response: Decodable { let result: String }

struct ErrorResponse: Decodable {
    let result: String
    let errors: [MangaDexAPIErrorResponse]
}

enum FollowResponse: Decodable {
    case success(Response)
    case failure(ErrorResponse)
    
    enum CodingKeys: CodingKey {
        case result
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        let result = try container.decode(String.self, forKey: .result)
        
        switch result {
        case "ok":
            try self = .success(.init(from: decoder))
        case "error":
            try self = .failure(.init(from: decoder))
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unexpected result type: \(result)"))
        }
    }
}

//struct FollowResponseEntity: MangaDexAPIEntity {
//    var id: UUID
//    
//    typealias ModelType = FollowResponse
//    
//    var url: URL {
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = Server.standard.rawValue
//        components.path = "/manga/\(id.uuidString.lowercased())/follow"
//        return components.url!
//    }
//}

struct Follow {
    let manga: UUID
    
    init(manga: UUID) {
        self.manga = manga
    }
}

extension Follow: MangaDexAPIRequest {
    typealias ModelType = FollowResponse
    
    func decode(_ data: Data) throws -> FollowResponse {
        return try JSONDecoder().decode(FollowResponse.self, from: data)
    }
    
    func execute() async throws -> FollowResponse {
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
    typealias ModelType = FollowResponse
    
    func decode(_ data: Data) throws -> FollowResponse {
        return try JSONDecoder().decode(FollowResponse.self, from: data)
    }
    
    func execute() async throws -> FollowResponse {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga/\(manga.uuidString.lowercased())/follow"
        
        return try await authenticatedDelete(at: components.url!)
    }
}
