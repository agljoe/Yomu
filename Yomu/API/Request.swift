//
//   swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-07.
//

import Foundation

// Base Https Requests
public enum MDApiError: Error {
    case unknownResponse
    case badRequest
    case unauthorizedRequest
    case forbiddenRequest
    case notFound
    case serviceUnavailable
    case invalidURL
}

extension MDApiError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownResponse:
            return String(localized: "Unknown response recived from server.")
        case .badRequest:
            return String(localized: "Request could not be completed, likely because the format was incorrect.")
        case .unauthorizedRequest:
            return String(localized: "Loged user is not authorized to make this request.")
        case .forbiddenRequest:
            return String(localized: "Request not allowed.")
        case .notFound:
            return String(localized: "Request target could not be found.")
        case .serviceUnavailable:
            return String(localized: "Service is currently unavailable.")
        case .invalidURL:
            return String(localized: "Could not find server at requested URL.")
        }
    }
}

public func post(url: URL, value: String?, content: Data?) async throws -> Data {
    var request = URLRequest(url: url)
    request.setValue(value, forHTTPHeaderField: "Content-Type")
    request.httpShouldHandleCookies = true
    request.timeoutInterval = 90
    request.httpMethod = "POST"
    
    if (content != nil) { request.httpBody = content }
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw httpError(for: (response as! HTTPURLResponse)) }
    
    return data
}

public func get(for url: URL) async throws -> Data {
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpShouldHandleCookies = true
    request.timeoutInterval = 90
    
    request.httpMethod = "GET"
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw httpError(for: (response as! HTTPURLResponse)) }
    return data
}

func httpError(for response: HTTPURLResponse) -> MDApiError {
    switch response.statusCode {
    case 400:
        return MDApiError.badRequest
    case 401:
        return MDApiError.unauthorizedRequest
    case 403:
        return MDApiError.forbiddenRequest
    case 404:
        return MDApiError.notFound
    case 503:
        return MDApiError.serviceUnavailable
    default:
        return MDApiError.unknownResponse
    }
}

// Health Check
public func healthCheck() async throws -> String {
    let urlString = "https://api.mangadex.org/ping"
    
    guard let url = URL(string: urlString) else { throw MDApiError.invalidURL }
    
    let data = try await get(for: url)
    let response = String(data: data, encoding: .utf8) ?? ""
    
    if response == "pong" { return response } else { throw MDApiError.serviceUnavailable }
}

// Manga requests TODO: caller handles errors
public func getManga(id: UUID) async throws -> Manga {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/\(id.uuidString)"
    components.queryItems = [
        URLQueryItem(name: "includes[]", value: "cover_art"),
        URLQueryItem(name: "includes[]", value: "artist"),
        URLQueryItem(name: "includes[]", value: "author")
    ]
    
    struct Root: Decodable { let data: MangaEntity }
    
    guard let url = components.url else { throw MDApiError.invalidURL }
    
    let data = try await get(for: url)
    let manga = try JSONDecoder().decode(Root.self, from: data)
    
    #if DEBUG
    print(manga.data)
    #endif
    
    return Manga(from: manga.data)
}

public func followManga(for id: UUID) async throws {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.managadex.org"
    components.path = "/manga/\(id.uuidString)/follow"
    
    guard let url = components.url else { throw MDApiError.invalidURL }
    
    try await authPost(url: url, value: "application/json", content: nil)
}

public func unfollowManga(for id: UUID) async throws {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.managadex.org"
    components.path = "/manga/\(id.uuidString)/unfollow"
    
    guard let url = components.url else { throw MDApiError.invalidURL }
    
    try await authDelete(for: url)
}

public func updateMangaReadingStatus(id: UUID, status: ReadingStatus) async throws {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.managadex.org"
    components.path = "/manga/\(id.uuidString)/status"
    
    guard let url = components.url else { throw MDApiError.invalidURL }
    
    struct Data: Codable, Sendable { let status: String }
    
    let content = try JSONEncoder().encode(Data(status: ReadingStatus.RawValue(status.rawValue)))
    try await authPost(url: url, value: "application/json", content: content)
}


//Chapter requests TODO: caller handles errors
public func getChapter(id: String) async throws -> Chapter {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/chapter/\(id)"

    guard let url = components.url else { throw MDApiError.badRequest }

    let data = try await get(for: url)
    let chapter = try JSONDecoder().decode(Chapter.self, from: data)
    return chapter
}

public func getChapters(id: UUID) async throws -> [Chapter] {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/\(id.uuidString)/feed"
    
    guard let url = components.url else { throw MDApiError.invalidURL }
    
    let data = try await get(for: url)
    let chapters = try JSONDecoder().decode([Chapter].self, from: data)
    return chapters
}

public func getChaptersFor(mangaId: UUID, completion: @escaping @Sendable (Int, Int, Int) -> Void) async throws -> [Chapter] {
    var compontents = URLComponents()
    compontents.scheme = "https"
    compontents.host = "api.mangadex.org"
    compontents.path = "/get/\(mangaId)/feed"
    compontents.queryItems = [
        URLQueryItem(name: "includes[]", value: "scanlation_group"),
        URLQueryItem(name: "includes[]", value: "user")
    ]
    
    guard let url = compontents.url else { throw MDApiError.invalidURL }
    
    struct Root: Decodable {
        let data: [Chapter]
        let limit: Int
        let offset: Int
        let total: Int
    }
    
    let data = try await get(for: url)
    let chapters = try JSONDecoder().decode(Root.self, from: data)
    completion(chapters.limit, chapters.offset, chapters.total)
    return chapters.data
}

// Cover requests TODO: caller handles errors
public func getCoverFor(id: UUID) async throws -> Cover {
    var compontents = URLComponents()
    compontents.scheme = "https"
    compontents.host = "api.mangadex.org"
    compontents.path = "/cover/\(id.uuidString)"
    
    guard let url = compontents.url else { throw MDApiError.invalidURL }
    
    struct Root: Decodable { let data: Cover } // TODO: refactor to CoverEntity
    
    let data = try await get(for: url)
    let cover = try JSONDecoder().decode(Root.self, from: data)
    return cover.data
}

public func getCoversFor(ids: [UUID], limit: Int?) async throws -> [Cover] {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/cover"
    
    let order: String = "desc"
    
    components.queryItems = []
    components.queryItems?.append(URLQueryItem(name: "limit", value: "\(limit ?? 100)"))
    for id in ids { components.queryItems?.append(URLQueryItem(name: "manga[]", value: id.uuidString.lowercased())) }
    components.queryItems?.append(URLQueryItem(name: "order[createdAt]", value: order))
    components.queryItems?.append(URLQueryItem(name: "order[updatedAt]", value: order))
    components.queryItems?.append(URLQueryItem(name: "order[volume]", value: order))
    
    guard let url = components.url else { throw MDApiError.invalidURL }
    
    struct Root: Decodable {
        let data: [Cover]
        let limit: Int
        let offset: Int
        let total: Int
    }
    
    let data = try await get(for: url)
    let covers = try JSONDecoder().decode(Root.self, from: data)
    
//    #if DEBUG
//    print(covers.data)
//    #endif
//    
    return covers.data
}

// Author / Artists requests TODO: caller handles errors
public func getAuthor(id: UUID) async throws -> Author {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/author/\(id.uuidString)"
    components.queryItems = [URLQueryItem(name: "includes[]", value: "manga")]
    
    guard let url = components.url else { throw MDApiError.invalidURL }
    
    struct Root: Decodable { let data: Author } // TODO: refactory to AuthorEntity / ArtistEntity
    
    let data = try await get(for: url)
    let author = try JSONDecoder().decode(Root.self, from: data)
    
    #if DEBUG
    print(author)
    #endif
    
    return author.data
}
