//
//  RandomMangaEntity.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-03-31.
//

import Foundation

/// An entity that represents the needed to fetch a random manga.
struct RandomMangaEntity: MangaDexAPIEntity {
    typealias ModelType = Manga
    
    let includedTags: [UUID]
    let includedTagsMode: IncludedTagsMode
    let excludedTags: [UUID]
    let excludedTagsMode: ExcludedTagsMode
    
    init(includedTags: [UUID] = [], includedTagsMode: IncludedTagsMode = .and, excludedTags: [UUID] = [], excludedTagsMode: ExcludedTagsMode = .and) {
        self.includedTags = includedTags
        self.includedTagsMode = includedTagsMode
        self.excludedTags = excludedTags
        self.excludedTagsMode = excludedTagsMode
    }
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.mangadex.org"
        components.path = "/manga/random"
        components.queryItems = [
            URLQueryItem(name: "includes[]", value: "manga"),
            URLQueryItem(name: "includes[]", value: "cover_art"),
            URLQueryItem(name: "includes[]", value: "author"),
            URLQueryItem(name: "includes[]", value: "artist"),
            URLQueryItem(name: "includes[]", value: "creator")
        ]
        
        if let contentRating = UserDefaults.standard.object(forKey: "contentRating") as? Rating {
            components.queryItems?.append(contentsOf: contentRating.value)
        }
        
        if !includedTags.isEmpty {
            components.queryItems?.append(contentsOf: self.includedTags.map { URLQueryItem(name: "includedTags[]", value: $0.uuidString.lowercased()) })
            components.queryItems?.append(URLQueryItem(name: "includedTagsMode", value: self.includedTagsMode.rawValue))
        }
        
        if !excludedTags.isEmpty {
            components.queryItems?.append(contentsOf: self.excludedTags.map { URLQueryItem(name: "excludedTags[]", value: $0.uuidString.lowercased()) })
            components.queryItems?.append(URLQueryItem(name: "excludedTagsMode", value: self.excludedTagsMode.rawValue))
        }
        
        return components.url!
    }
}
