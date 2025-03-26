//
//  AuthorListRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-25.
//

import Foundation

private extension MangaDexAPIEntity {
    var compents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.mangadex.org"
        components.path = path
        return components
    }
}

struct AuthorListEntity: MangaDexAPIEntity {
    typealias ModelType = [Author]
    
    var path: String {
        return "/author"
    }
}

struct AuthorListRequest {
    var ids: [UUID]
    var limit: Int
    var offset: Int
    var order: Order
    
    let entity: AuthorListEntity
    
    init(ids: [UUID], limit: Int = 10, offset: Int = 0, order: Order, entity: AuthorListEntity) {
        self.ids = ids
        self.limit = limit
        self.offset = offset
        self.order = order
        self.entity = entity
    }
}

extension AuthorListRequest: MangaDexAPIRequest {
    typealias ModelType = [Author]
    
    func decode(_ data: Data) throws -> [Author] {
        return try JSONDecoder().decode(Wrapper<[Author]>.self, from: data).data
    }
    
    func execute() async throws -> [Author] {
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "limit", value: "\(self.limit)"), URLQueryItem(name: "offset", value: "\(self.offset)")]
        queryItems.append(contentsOf: ids.map { URLQueryItem(name: "ids[]", value: $0.uuidString.lowercased() )} )
        queryItems.append(URLQueryItem(name: "order", value: self.order.rawValue))
        var components = entity.compents
        components.queryItems = queryItems
        
        return try await get(from: components.url!)
    }
}
