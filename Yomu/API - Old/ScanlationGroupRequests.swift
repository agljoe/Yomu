//
//  ScanlationGroupRequests.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-10.
//

import Foundation

/// Retrives and decodes a ``ScanlationGroup`` specified by the given `id`.
///
/// - Parameters
///     - id: the `UUID` of a specific scanlation group
///     - queryParameters: an array of `URLQueryItem` sent with this request.
///
/// - Throws: `MDApiError.invalidUrl` if a url could not be constructed from `components`.
/// - Throws:  Some `DeocdingError` if the recived JSON data could not be decoded.
///
/// - Returns: a ``ScanlationGroup``
///
/// > Important:
///     See [MangaDex API Redoc](https://api.mangadex.org/docs/redoc.html#tag/ScanlationGroup/operation/get-group-id) for a list of available query parameters for this endpoint.
///
/// ### See Also
/// [ReferenceExpansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
/// ### Endpoint
///     /group/{id}
public func getScanlationGroup(_ id: UUID, queryParameters: [URLQueryItem] = [URLQueryItem(name: "includes[]", value: "leader"), URLQueryItem(name: "includes[]", value: "member")]) async throws -> ScanlationGroup {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/group/\(id.uuidString.lowercased())"
    
    if (!queryParameters.isEmpty) { components.queryItems = queryParameters }
    
    guard let url = components.url else {
        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
    }
    
    struct Root: Decodable { let data: ScanlationGroup }
    
    let data = try await get(from: url)
    let group = try JSONDecoder().decode(Root.self, from: data)
    return group.data
}
