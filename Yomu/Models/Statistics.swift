//
//  Statistics.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-10.
//

import Foundation

/// A collection of statistics for a given chapter.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/Statistics/operation/get-statistics-chapter-uuid)
public struct ChapterStatistics: Decodable, Identifiable, Sendable {
    /// The UUID of the chapter these statistics belong to.
    public let id: UUID
    
    /// The id of the comments thread for a chapter.
    let threadId: Int?
    
    /// The total number of comments in a chapter's comments thread.
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
    
    /// Creates a ``ChapterStatistics`` instance initialiezed with placeholder values.
    public init() {
        self.id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        self.threadId = nil
        self.repliesCount = nil
    }
    
    /// Creates a ``ChapterStatistics`` instance initialized by the given values.
    public init(id: UUID, threadId: Int?, repliesCount: Int?) {
        self.id = id
        self.threadId = threadId
        self.repliesCount = repliesCount
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: any Decoder) throws {
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        self.id = UUID(uuidString: dynamicContainer.allKeys.first!.stringValue)!
        
        let container = try dynamicContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .init(stringValue: dynamicContainer.allKeys.first!.stringValue)!)
        
        if let _: [String: Int] = try container.decodeIfPresent([String: Int].self, forKey: .comments) {
            let commentsContainer = try container.nestedContainer(keyedBy: CommentsCodingKeys.self, forKey: .comments)
            self.threadId = try commentsContainer.decodeIfPresent(Int.self, forKey: .threadId)
            self.repliesCount = try commentsContainer.decodeIfPresent(Int.self, forKey: .repliesCount)
        } else {
            self.threadId = nil
            self.repliesCount = nil
        }
    }
}

public struct MangaStatistics: Decodable, Identifiable, Sendable {
    public let id: UUID
    let threadId: Int?
    let repliesCount: Int?
    let average: Double?
    let bayesian: Double
    let distribution: [String: Int]?
    let follows: Int
    
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
      case comments, rating, follows
    }
    
    private enum CommentsCodingKeys: CodingKey {
        case threadId, repliesCount
    }
    
    private enum RatingCodingKeys: CodingKey {
        case average, bayesian, distribution
    }
    
    public init() {
        self.id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        self.threadId = nil
        self.repliesCount = nil
        self.average = nil
        self.bayesian = 0
        self.distribution = nil
        self.follows = 0
    }
    
    public init(id: UUID, threadId: Int?, repliesCount: Int?, average: Double?, bayesian: Double, distribution: [String: Int]?, follows: Int) {
        self.id = id
        self.threadId = threadId
        self.repliesCount = repliesCount
        self.average = average
        self.bayesian = bayesian
        self.distribution = distribution
        self.follows = follows
    }
    
    public init(from decoder: any Decoder) throws {
        let dynamicConatiner = try decoder.container(keyedBy: DynamicCodingKeys.self)
        self.id = UUID(uuidString: dynamicConatiner.allKeys.first!.stringValue)!
        
        let container = try dynamicConatiner.nestedContainer(keyedBy: CodingKeys.self, forKey: .init(stringValue: dynamicConatiner.allKeys.first!.stringValue)!)
        if let _: [String: Int] = try container.decodeIfPresent([String: Int].self, forKey: .comments) {
            let commentsContainer = try container.nestedContainer(keyedBy: CommentsCodingKeys.self, forKey: .comments)
            self.threadId = try commentsContainer.decodeIfPresent(Int.self, forKey: .threadId)
            self.repliesCount = try commentsContainer.decodeIfPresent(Int.self, forKey: .repliesCount)
        } else {
            self.threadId = nil
            self.repliesCount = nil
        }
        
        let ratingContainer = try container.nestedContainer(keyedBy: RatingCodingKeys.self, forKey: .rating)
        self.average = try ratingContainer.decode(Double.self, forKey: .average)
        self.bayesian = try ratingContainer.decode(Double.self, forKey: .bayesian)
        self.distribution = try ratingContainer.decodeIfPresent([String: Int].self, forKey: .distribution)
        self.follows = try container.decode(Int.self, forKey: .follows)
    }
}
