//
//  Chapter.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-11.
//

import Foundation


public struct Chapter: Decodable, Identifiable, Sendable {
    public let id: UUID
    let title: String?
    let volume: String?
    let chapter: String
    let pages: Int
    let translatedLanguage: String
    let externalUrl: String?
    let version: Int
    let createdAt: Date
    let updatedAt: Date
    let publishAt: Date
    let readableAt: Date
    let scanlationGroup: ScanlationGroup?
    let user: User?
    let parentManga: ParentManga?
    
    enum CodingKeys: String, CodingKey {
        case id, attributes, relationships
    }
    
    enum AttributeCodingKeys: String, CodingKey {
        case title, volume, chapter, pages, translatedLanguage, externalUrl, version, createdAt, updatedAt, publishAt, readableAt
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.title = try attributesContainer.decodeIfPresent(String.self, forKey: .title)
        self.volume = try attributesContainer.decodeIfPresent(String.self, forKey: .volume)
        self.chapter = try attributesContainer.decode(String.self, forKey: .chapter)
        self.pages = try attributesContainer.decode(Int.self, forKey: .pages)
        self.translatedLanguage = try attributesContainer.decode(String.self, forKey: .translatedLanguage)
        
        self.externalUrl = try attributesContainer.decodeIfPresent(String.self, forKey: .externalUrl)
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.createdAt =  RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .createdAt))!
        self.updatedAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .updatedAt))!
        self.publishAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .publishAt))!
        self.readableAt = RFC3339DateFormatter.date(from: try attributesContainer.decode(String.self, forKey: .readableAt))!
        
        var scanlationGroup: ScanlationGroup?
        var uploader: User?
        var parentManga: ParentManga?
        
        do {
            let relationships = try container.decodeIfPresent([ChapterRelationship].self, forKey: .relationships)
            for relationship in relationships ?? [ChapterRelationship]() {
                switch relationship {
                case .scanlation_group(let scanlation_group):
                    scanlationGroup = scanlation_group
                case .user(let user):
                    uploader = user
                case .manga(let manga):
                    parentManga = manga
                }
            }
        }
        
        self.scanlationGroup = scanlationGroup ?? nil
        self.user = uploader ?? nil
        self.parentManga = parentManga ?? nil
    }
}

struct ParentManga: Decodable, Identifiable, Sendable {
    public let id: UUID
    let title: [String: String] // TODO: flatten to just string
    let originalLanuage: String
    
    enum CodingKeys: String, CodingKey {
        case id, attributes
    }
    
    enum AttributeCodingKeys: String, CodingKey {
        case title, originalLanguage
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.title = try attributesContainer.decode([String: String].self, forKey: .title)
        self.originalLanuage = try attributesContainer.decode(String.self, forKey: .originalLanguage)
    }
}

struct AtHomeChapterComponents: Decodable, Sendable {
    let result: String
    let baseUrl: String
    let hash: String
    let data: [String]
    let dataSaver: [String]
    
    enum CodingKeys: String, CodingKey {
        case result, baseUrl, chapter
    }
    
    enum ChapterCodingKeys: String, CodingKey {
        case hash, data, dataSaver
    }
    
    init() {
        self.result = ""
        self.baseUrl = ""
        self.hash = ""
        self.data = []
        self.dataSaver = []
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.result = try container.decode(String.self, forKey: .result)
        self.baseUrl = try container.decode(String.self, forKey: .baseUrl)
        
        let chapterContainer = try container.nestedContainer(keyedBy: ChapterCodingKeys.self, forKey: .chapter)
        self.hash = try chapterContainer.decode(String.self, forKey: .hash)
        self.data = try chapterContainer.decode([String].self, forKey: .data)
        self.dataSaver = try chapterContainer.decode([String].self, forKey: .dataSaver)
        
    }
}
