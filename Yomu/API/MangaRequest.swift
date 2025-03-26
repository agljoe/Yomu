//
//  MangaEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-04.
//

import Foundation

private extension MangaDexAPIEntity {
    /// The endpoint at which a a specified manga's details can be requested from.
    ///
    /// This URL aslo includes the necessary 
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.mangadex.org"
        components.path = path
        components.queryItems = [
            URLQueryItem(name: "includes[]", value: "manga"),
            URLQueryItem(name: "includes[]", value: "cover_art"),
            URLQueryItem(name: "includes[]", value: "author"),
            URLQueryItem(name: "includes[]", value: "artist"),
            URLQueryItem(name: "includes[]", value: "creator")]
        return components.url!
    }
}

///
struct MangaEntity: MangaDexAPIEntity {
    /// The model type that represents the data ...
    typealias ModelType = Manga
    var id: UUID
    
    var path: String {
        return "/manga/\(id.uuidString.lowercased())"
    }
}

/// A manga request represents a call to the endpoint /manga/{id}.
struct MangaRequest {
    /// The entity to be fetched by this request.
    let entity: MangaEntity
    
    /// Creates and
    init(entity: MangaEntity) {
        self.entity = entity
    }
}

extension MangaRequest: MangaDexAPIRequest {
    typealias ModelType = Manga
    
    func decode(_ data: Data) throws -> ModelType {
        return try JSONDecoder().decode(Wrapper<Manga>.self, from: data).data
    }
    
    func execute() async throws -> Manga {
        return try await get(from: entity.url)
    }
}
