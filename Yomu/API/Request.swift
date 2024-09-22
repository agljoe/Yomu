//
//  Request.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-07.
//

import Foundation

public class Request {
        
    public enum MDApiError: Error {
        case unknownResponse
        case badRequest
        case unauthorizedRequest
        case forbiddenRequest
        case notFound
        case serviceUnavailable
    }
    
    
    public func post(url: URL, value: String, content: Data) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(value, forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = true
        request.timeoutInterval = 90
        
        request.httpMethod = "POST"
        
        request.httpBody = content
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw try httpError(for: (response as! HTTPURLResponse)) }
        
        return data
    }
    
    public func get(for url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = true
        request.timeoutInterval = 90
        
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw try httpError(for: (response as! HTTPURLResponse)) }
        return data
    }
    
    private func httpError(for response: HTTPURLResponse) throws -> MDApiError {
        switch response.statusCode {
        case 400:
            throw MDApiError.badRequest
        case 401:
            throw MDApiError.unauthorizedRequest
        case 403:
            throw MDApiError.forbiddenRequest
        case 404:
            throw MDApiError.notFound
        case 503:
            throw MDApiError.serviceUnavailable
        default:
            throw MDApiError.unknownResponse
        }
    }
}

public func healthCheck() async throws -> String {
    let urlString = "https://api.mangadex.org/ping"
    
    guard let url = URL(string: urlString) else { throw Request.MDApiError.badRequest }
    
    let data = try await Request().get(for: url)
    let response = String(data: data, encoding: .utf8) ?? ""
    
    if response == "pong" { return "healthy" } else { throw Request.MDApiError.serviceUnavailable }
}

public func getManga(id: String) async throws -> Manga {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/\(id)"
    components.queryItems = [
        URLQueryItem(name: "includes[]", value: "cover_art"),
        URLQueryItem(name: "includes[]", value: "artist"),
        URLQueryItem(name: "includes[]", value: "author")
    ]

    struct Root: Decodable { let data: MangaEntity }

    guard let url = components.url else { throw Request.MDApiError.badRequest }

    let data = try await Request().get(for: url)
    
    let manga = try! JSONDecoder().decode(Root.self, from: data)
    
    #if DEBUG
    print(manga.data)
    #endif
    
    return Manga(from: manga.data)
}

public func getChapters(id: String) async throws -> [Chapter] {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/manga/\(id)/feed"
    
    guard let url = components.url else { throw Request.MDApiError.badRequest }
    
    let data = try await Request().get(for: url)
    let chapters = try JSONDecoder().decode([Chapter].self, from: data)
    return chapters
}

public func getCover(id: String) async throws -> () {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/cover/\(id)"
    
    guard let url = components.url else { throw Request.MDApiError.badRequest }
    
    struct Root: Decodable { let data: Cover }
    
    let data = try await Request().get(for: url)
    let cover = try JSONDecoder().decode(Root.self, from: data)
    
    #if DEBUG
    print(cover.data)
    #endif
    
}

public func getAuthor(id: String) async throws -> Author {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/author/\(id)"
    components.queryItems = [URLQueryItem(name: "includes[]", value: "manga")]

    guard let url = components.url else { throw Request.MDApiError.badRequest }
    
    struct Root: Decodable { let data: Author}
    
    let data = try await Request().get(for: url)
    let author = try JSONDecoder().decode(Root.self, from: data)
    #if DEBUG
    print(author)
    #endif
    return author.data
}

public func getChaptersFor(mangaId: UUID) async throws -> [Chapter] {
    var compontents = URLComponents()
    compontents.scheme = "https"
    compontents.host = "api.mangadex.org"
    compontents.path = "/get/\(mangaId)/feed"
    compontents.queryItems = [
        URLQueryItem(name: "includes[]", value: "scanlation_group"),
        URLQueryItem(name: "includes[]", value: "user")
    ]
    
    guard let url = compontents.url else { throw  Request.MDApiError.badRequest }
    
    struct Root: Decodable {
        let data: [Chapter]
        let limit: Int
        let offset: Int
        let total: Int
    }
    
    let data = try await Request().get(for: url)
    let chapters = try JSONDecoder().decode(Root.self, from: data)
    // track limit, offset, and total
    return chapters.data
}
