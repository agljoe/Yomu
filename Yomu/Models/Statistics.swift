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
struct ChapterStatistics: Decodable, Equatable, Hashable, Identifiable, Sendable {
    /// The UUID of the chapter these statistics belong to.
    let id: UUID
    
    /// The id of the comments thread for a specific chapter.
    let threadId: Int?
    
    /// The total number of comments in a specific chapter's comments thread.
    let repliesCount: Int?
    
    /// Used to get the chapter UUID which is the first key in the returned JSON data.
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
    
    /// Creates a new instance by decoding from the given decoder.
    init(from decoder: any Decoder) throws {
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

extension ChapterStatistics {
    static func == (lhs: ChapterStatistics, rhs: ChapterStatistics) -> Bool {
        return lhs.id == rhs.id && rhs.threadId == lhs.threadId
    }
}

/// A collection of statistics for a given chapter.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/Statistics/operation/get-statistics-manga-uuid)
/// [Bayesian Ratings](https://api.mangadex.org/docs/03-manga/statistics/)
struct MangaStatistics: Decodable, Equatable, Hashable, Identifiable, Sendable {
    /// The UUID of the manga these statistics belong to.
    let id: UUID
    
    /// The id of the comments thread for a  specificmanga.
    let threadId: Int?
    
    /// The total number of replies in a specific manga's comments thread.
    let repliesCount: Int?
    
    /// The true mean of a specific manga's rating scores.
    ///
    /// Manga are scored on a scale of 1 to 10 stars inclusive.
    let average: Double?
    
    /// The bayesian weighted average of a specific manga's rating scores.
    let bayesian: Double
    
    /// The distribution of a manga's rating scores/
    let distribution: [String: Int]?
    
    /// The total number of users who follow a specific manga.
    let follows: Int
    
    /// Used to get the manga UUID which is the first key in the returned JSON data.
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
    
    /// Creates a new instance by decoding from the given decoder.
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

extension MangaStatistics {
    static func == (lhs: MangaStatistics, rhs: MangaStatistics) -> Bool {
        return lhs.id == rhs.id && lhs.threadId == rhs.threadId
    }
}
