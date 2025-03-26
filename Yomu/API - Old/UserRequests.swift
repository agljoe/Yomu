//
//  UserRequests.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-10.
//

import Foundation

/// Retrieves a ``User`` specified by the given `id`.
///
/// - Parameter id: the of the user to retrieve.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws:  Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: a ``User``
/// ### Endpoint
///     /user/{id}
public func getUser(_ id: UUID) async throws -> User {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/user/\(id.uuidString.lowercased())"
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable { let data: User }
    
    let data = try await get(from: url)
    let user = try JSONDecoder().decode(Root.self, from: data)
    return user.data
}
