//
//  UpdateMangaReadingStatusRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-31.
//

import Foundation

private struct ReadingStatusUpdate: Encodable {
    let id: UUID
    let status: String?
    
    init(id: UUID, status: ReadingStatus) {
        self.id = id
        switch status {
        case .none: self.status = nil
        default : self.status = status.rawValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(status)
    }
}

extension ReadingStatusUpdate {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga/\(id.uuidString.lowercased())/status"
        return components.url!
    }
}

struct UpdateMangaReadingStatusRequest {
    fileprivate let status: ReadingStatusUpdate
    
    init(for id: UUID, to status: ReadingStatus) {
        self.status = .init(id: id, status: status)
    }
}

extension UpdateMangaReadingStatusRequest: MangaDexAPIRequest {
    typealias ModelType = Response
    
    func decode(_ data: Data) throws -> Response {
        return Response(result: "ok")
    }
    
    func execute() async throws -> Response {
        let body = try JSONEncoder().encode(status)
        try await authenticatedPost(at: status.url, with: body)
        return try decode(Data())
    }
}
