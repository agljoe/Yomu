//
//  AuthorRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-25.
//

import Foundation

private extension MangaDexAPIEntity {
    var url: URL {
        var compontents = URLComponents()
        compontents.scheme = "https"
        compontents.host = "api.mangadex.org"
        compontents.path = path
        compontents.queryItems = [
            URLQueryItem(name: "includes[]", value: "manga")
        ]
        return compontents.url!
    }
}

struct AuthorEntity: MangaDexAPIEntity {
    typealias ModelType = Author
    var id: UUID
    
    var path: String {
        return "/author/\(id.uuidString.lowercased())"
    }
}

struct AuthorRequest {
    let entity: AuthorEntity
    
    init(entity: AuthorEntity) {
        self.entity = entity
    }
}

extension AuthorRequest: MangaDexAPIRequest {
    typealias ModelType = Author
    
    func decode(_ data: Data) throws -> Author {
        return try JSONDecoder().decode(Wrapper<Author>.self, from: data).data
    }
    
    func execute() async throws -> Author {
        return try await get(from: entity.url)
    }
}
