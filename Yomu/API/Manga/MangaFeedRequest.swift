//
//  MangaFeedRequest.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-01.
//

import Foundation

struct MangaFeedEntity: MangaDexAPIEntity {
    var id: UUID
    var limit: Int
    var offset: Int
    
    init(id: UUID, limit: Int = 10, offset: Int = 0) {
        self.id = id
        self.limit = limit
        self.offset = offset
    }
    
    typealias ModelType = [Chapter]
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Server.standard.rawValue
        components.path = "/manga/\(id)/feed"
        components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)")]
        
        if let translatedLanguage = UserDefaults.standard.array(forKey: "translatedLanguagee") as? [String] {
            components.queryItems?.append(contentsOf: translatedLanguage.map { URLQueryItem(name: "translatedLanguage[]", value: $0) })
        } else { components.queryItems?.append(URLQueryItem(name: "tranlsatedLanguage[]", value: "en"))}
        
        if let excludedGroups = UserDefaults.standard.array(forKey: "excludedGroupd") as? [String] {
            components.queryItems?.append(contentsOf: excludedGroups.map { URLQueryItem(name: "excludedGroups[]", value: $0) })
        }
        
        if let excludedUploaders = UserDefaults.standard.array(forKey: "excludedUploaders") as? [String] {
            components.queryItems?.append(contentsOf: excludedUploaders.map { URLQueryItem(name: "excludedUploaders[]", value: $0) })
        }
        
        components.queryItems?.append(URLQueryItem(name: "order[chapter]", value: Order.desc.rawValue))
        components.queryItems?.append(contentsOf: [
            URLQueryItem(name: "includes[]", value: "scanlation_group"),
            URLQueryItem(name: "includes[]", value: "user")
        ])
        
        return components.url!
    }
}
