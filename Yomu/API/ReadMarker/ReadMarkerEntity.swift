//
//  ReadMarkerEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-05.
//

import Foundation

/// An entity representing the necessary components for fetching the UUIDs chapters that
/// have be read for a specified manga.
struct ReadMarkerEntity: MangaDexAPIEntity {
    /// The UUID of the manga whose chapter read markers are being retrieved.
    var id: UUID
    
    typealias ModelType = [String]
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga/\(id.uuidString.lowercased())/read"
        return components.url!
    }
    
    var requiresAuthentication: Bool { true }
}

/// A group of chapters whose read markers are being updated.
struct ReadMarkerUpdate: Encodable {
    /// The UUID of the manga the given chapters belong to.
    let mangaID: UUID
    
    /// The chapters whose marker will be set to read.
    let chapterIdsRead: [String]?
    
    /// The chapters whose marker will be set to unread.
    let chapterIdsUnread: [String]?
    
    /// The possible JSON keys for this type.
    private enum CodingKeys: String, CodingKey {
        case chapterIdsRead, chapterIdsUnread
    }
    
    /// Creates a new `ReadMarkerUpdate` instance for the specified values.
    ///
    /// - Parameters:
    ///     - mangaID: the UUID of the manga whose chapter read markers are being updated.
    ///     - chapterIdsRead: an arrary of chapter UUID strings whose read markers are being set to read.
    ///     - chapterIdsUnread:  an arrary of chapter UUID strings whose read markers are being set to unread.
    ///
    /// - Returns: a newly created `ReadMarkerUpdate` initalized to the given values..
    init(mangaID: UUID, chapterIdsRead: [String]? = nil, chapterIdsUnread: [String]? = nil) {
        self.mangaID = mangaID
        self.chapterIdsRead = chapterIdsRead
        self.chapterIdsUnread = chapterIdsUnread
    }
    
    /// Creates a new `ReadMarkerUpdate` instance for the specified values.
    ///
    /// - Parameters:
    ///     - mangaID: the UUID of the manga whose chapter read markers are being updated.
    ///     - chapterIdsRead: an arrary of chapter UUIDs whose read markers are being set to read.
    ///     - chapterIdsUnread:  an arrary of chapter UUIDs whose read markers are being set to unread.
    ///
    /// - Returns: a newly created `ReadMarkerUpdate` initalized to the given values..
    init(mangaID: UUID, chapterIdsRead: [UUID]? = nil, chapterIdsUnread: [UUID]? = nil) {
        self.mangaID = mangaID
        self.chapterIdsRead = chapterIdsRead?.map { $0.uuidString.lowercased() }
        self.chapterIdsUnread = chapterIdsUnread?.map { $0.uuidString.lowercased() }
    }
    
    /// Encodes this value into the given encoder.
    ///
    /// - Parameter encoder: the encoder to write data to.
    ///
    /// - Throws: an `EncodingError` if any values are invalid for the given encoders format.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(chapterIdsRead, forKey: .chapterIdsRead)
        try container.encodeIfPresent(chapterIdsUnread, forKey: .chapterIdsUnread)
    }
}

extension ReadMarkerUpdate {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga/\(mangaID.uuidString.lowercased())/read"
        //components.queryItems = [URLQueryItem(name: "updateHisttory", value: "\(true)")]
        return components.url!
    }
}
    
struct UpdateReadMarkerRequest {
    let markers: ReadMarkerUpdate
    
    init(mangaID: UUID, chapterIdsRead: [String]? = nil, chapterIdsUnread: [String]? = nil) {
        self.markers = .init(mangaID: mangaID, chapterIdsRead: chapterIdsRead, chapterIdsUnread: chapterIdsUnread)
    }
    
    init(mangaID: UUID, chapterIdsRead: [UUID]? = nil, chapterIdsUnread: [UUID]? = nil) {
        self.markers = .init(mangaID: mangaID, chapterIdsRead: chapterIdsRead, chapterIdsUnread: chapterIdsUnread)
    }
}


extension UpdateReadMarkerRequest: MangaDexAPIRequest {
    typealias ModelType = Response?
    
    func decode(_ data: Data) throws -> Response? {
        fatalError("This function should never be called.")
    }
    
    func execute() async throws -> Response? {
        let body = try JSONEncoder().encode(self.markers)
        guard body.count < 10240 && !body.isEmpty else { throw MangaDexAPIError.badRequest(context: "The request body is too large or empty") }
        try await authenticatedPost(at: markers.url)
        return nil
    }
}
