//
//  Author.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-11.
//

import Foundation

public struct Author: Decodable, Identifiable, Sendable {
    public let id: UUID
    let name: String
    let imageUrl: String?
    let biography: LocalizedLanguage?
    let twitter: String?
    let pixiv: String?
    let melonBook: String?
    let fanBox: String?
    let booth: String?
    let nicoVideo: String?
    let skeb: String?
    let fantia: String?
    let tumblr: String?
    let youtube: String?
    let weibo: String?
    let naver: String?
    let namicomi: String?
    let website: String?
    let createdAt: String?
    let updatedAt: String?
    let version: Int?
    let realtedManga: [MangaEntity]?
    
    enum CodingKeys: CodingKey {
        case id, type, attributes, relationships
    }
    
    enum AttributesCodingKeys: CodingKey {
        case name, imageUrl, biography, twitter, pixiv, melonBook, fanBox, booth, nicoVideo, skeb, fantia, tumblr, youtube, weibo, naver, namicomi, website, createdAt, updatedAt, version
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
        self.name = try attributesContainer.decode(String.self, forKey: .name)
        
        self.imageUrl = try attributesContainer.decodeIfPresent(String.self, forKey: .imageUrl)
        
        self.biography = try attributesContainer.decode(LocalizedLanguage.self, forKey: .biography)
        
        self.twitter = try attributesContainer.decodeIfPresent(String.self, forKey: .twitter)
        self.pixiv = try attributesContainer.decodeIfPresent(String.self, forKey: .pixiv)
        self.melonBook = try attributesContainer.decodeIfPresent(String.self, forKey: .melonBook)
        self.fanBox = try attributesContainer.decodeIfPresent(String.self, forKey: .fanBox)
        self.booth = try attributesContainer.decodeIfPresent(String.self, forKey: .booth)
        self.nicoVideo = try attributesContainer.decodeIfPresent(String.self, forKey: .nicoVideo)
        self.skeb = try attributesContainer.decodeIfPresent(String.self, forKey: .skeb)
        self.fantia = try attributesContainer.decodeIfPresent(String.self, forKey: .fantia)
        self.tumblr = try attributesContainer.decodeIfPresent(String.self, forKey: .tumblr)
        self.youtube = try attributesContainer.decodeIfPresent(String.self, forKey: .youtube)
        self.weibo = try attributesContainer.decodeIfPresent(String.self, forKey: .weibo)
        self.naver = try attributesContainer.decodeIfPresent(String.self, forKey: .naver)
        self.namicomi = try attributesContainer.decodeIfPresent(String.self, forKey: .namicomi)
        self.website = try attributesContainer.decodeIfPresent(String.self, forKey: .website)
        
        self.createdAt = try attributesContainer.decode(String.self, forKey: .createdAt)
        self.updatedAt = try attributesContainer.decode(String.self, forKey: .updatedAt)
        
        self.version = try attributesContainer.decode(Int.self, forKey: .version)
        
        self.realtedManga = try container.decodeIfPresent([MangaEntity].self, forKey: .relationships)
    }
}
