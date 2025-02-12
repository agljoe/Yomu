//
//  Statistics.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-10.
//

import Foundation

public struct ChapterStatistics: Decodable, Identifiable, Sendable {
    public let id: UUID
    let threadId: Int?
    let repliesCount: Int?
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    private enum CodingKeys: CodingKey {
        case comments
    }
    
    private enum CommentsCodingKeys: CodingKey {
        case threadId, repliesCount
    }
    
    public init(from decoder: any Decoder) throws {
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        self.id = UUID(uuidString: dynamicContainer.allKeys.first!.stringValue)!
        let container = try dynamicContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .init(stringValue: dynamicContainer.allKeys.first!.stringValue)!)
        if let _: [String: [[String: Int]]] = try container.decodeIfPresent([String: [[String: Int]]].self, forKey: .comments) {
            let commentsContainer = try container.nestedContainer(keyedBy: CommentsCodingKeys.self, forKey: .comments)
            self.threadId = try commentsContainer.decodeIfPresent(Int.self, forKey: .threadId)
            self.repliesCount = try commentsContainer.decodeIfPresent(Int.self, forKey: .repliesCount)
        } else {
            self.threadId = nil
            self.repliesCount = nil
        }
    }
}

public struct MangaStatistics: Decodable, Sendable {
    let threadId: Int
    let repliesCount: Int
    let average: Double?
    let baysean: Double
    let distribution: [String: Int]
}
