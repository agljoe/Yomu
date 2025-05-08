//
//  Statistics.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-10.
//

import Foundation

protocol Statistics: Decodable, Equatable, Hashable, Sendable  {
    var threadId: Int? { get }
}

extension Statistics {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.threadId == rhs.threadId
    }
}

/// Similar to the generic wrapper struct, all JSON data returned from
/// /statistics endpoints have a first key of "statistics".
struct StatisticsWrapper<T: Statistics>: Decodable { let statistics: T }

/// Similar to the generic wrapper struct, all JSON data returned from
/// /statistics endpoints have a first key of "statistics".
struct GroupedStatisticsWrapper<T: Statistics>: Decodable { let statistics: [String: T] }

/// A collection of statistics for a given chapter.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/Statistics/operation/get-statistics-chapter-uuid)
struct ChapterStatistics: Statistics {
    /// The id of the comments thread for a specific chapter.
    let threadId: Int?
    
    /// The total number of comments in a specific chapter's comments thread.
    let repliesCount: Int?
    
    /// Used to get the chapter UUID which is the first key in the returned JSON data.
    private struct DynamicCodingKeys: CodingKey {
        /// The string value of this dynamic key.
        var stringValue: String
        
        /// Creates the string value for this key if possible.
        ///
        /// - Parameter stringValue: The string this key is initialized to.
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        /// The integer value of this dynamic key.
        var intValue: Int?
        
        /// Creates the integer value for this key if possible.
        ///
        /// - Parameter intValue: The integer this key is initialized to.
        init?(intValue: Int) {
            return nil
        }
    }

    /// The base coding keys for this struct.
    private enum CodingKeys: CodingKey {
        case comments
    }
    
    /// The nested coding keys found through the comments keypath.
    private enum CommentsCodingKeys: CodingKey {
        case threadId, repliesCount
    }
    
    /// Creates a new instance by decoding from the given decoder.
    init(from decoder: any Decoder) throws {
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        if let container = try? dynamicContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .init(stringValue: dynamicContainer.allKeys.first!.stringValue)!) {
            if let commentsContainer = try? container.nestedContainer(keyedBy: CommentsCodingKeys.self, forKey: .comments) {
                self.threadId = try commentsContainer.decodeIfPresent(Int.self, forKey: .threadId)
                self.repliesCount = try commentsContainer.decodeIfPresent(Int.self, forKey: .repliesCount)
            } else {
                self.threadId = nil
                self.repliesCount = nil
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let commentsContainer = try? container.nestedContainer(keyedBy: CommentsCodingKeys.self, forKey: .comments) {
                self.threadId = try commentsContainer.decodeIfPresent(Int.self, forKey: .threadId)
                self.repliesCount = try commentsContainer.decodeIfPresent(Int.self, forKey: .repliesCount)
            } else {
                self.threadId = nil
                self.repliesCount = nil
            }
        }
    }
}

/// A collection of statistics for a given chapter.
///
/// ### See Also
/// [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html#tag/Statistics/operation/get-statistics-manga-uuid)
/// [Bayesian Ratings](https://api.mangadex.org/docs/03-manga/statistics/)
struct MangaStatistics: Statistics {
    /// The id of the comments thread for a  specificmanga.
    let threadId: Int?
    
    /// The total number of replies in a specific manga's comments thread.
    let repliesCount: Int?
    
    /// The true mean of a specific manga's rating scores.
    ///
    /// Manga are scored on a scale of 1 to 10 stars inclusive.
    let average: Double?
    
    /// The bayesian weighted average of a specific manga's rating scores.
    let bayesian: Double?
    
    /// The distribution of a manga's rating scores.
    let distribution: [String: Int]?
    
    /// The total number of users who follow a specific manga.
    let follows: Int
    
    /// Used to get the manga UUID which is the first key in the returned JSON data.
    private struct DynamicCodingKeys: CodingKey {
        /// The string value of this dynamic key.
        var stringValue: String
        
        /// Creates the string value for this key if possible.
        ///
        /// - Parameter stringValue: The string this key is initialized to.
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        /// The integer value of this dynamic key.
        var intValue: Int?
        
        /// Creates the integer value for this key if possible.
        ///
        /// - Parameter intValue: The integer this key is initialized to.
        init?(intValue: Int) {
            return nil
        }
    }
    
    /// The base coding keys for this struct.
    private enum CodingKeys: CodingKey {
      case comments, rating, follows
    }
    
    /// The nested coding keys found through the comments keypath.
    private enum CommentsCodingKeys: CodingKey {
        case threadId, repliesCount
    }
    
    /// The nested coding keys found through the rating keypath.
    private enum RatingCodingKeys: CodingKey {
        case average, bayesian, distribution
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: any Decoder) throws {
        let dynamicConatiner = try decoder.container(keyedBy: DynamicCodingKeys.self)
        let firstKey: DynamicCodingKeys = .init(stringValue: dynamicConatiner.allKeys.first!.stringValue) ?? .init(intValue: 0)!
        
        if let _ = UUID(uuidString: firstKey.stringValue) {
            let container = try dynamicConatiner.nestedContainer(keyedBy: CodingKeys.self, forKey: firstKey)
            if  let commentsContainer = try? container.nestedContainer(keyedBy: CommentsCodingKeys.self, forKey: .comments) {
                self.threadId = try commentsContainer.decodeIfPresent(Int.self, forKey: .threadId)
                self.repliesCount = try commentsContainer.decodeIfPresent(Int.self, forKey: .repliesCount)
            } else {
                self.threadId = nil
                self.repliesCount = nil
            }
            
            let ratingContainer = try container.nestedContainer(keyedBy: RatingCodingKeys.self, forKey: .rating)
            self.average = try ratingContainer.decodeIfPresent(Double.self, forKey: .average)
            self.bayesian = try ratingContainer.decode(Double.self, forKey: .bayesian)
            self.distribution = try ratingContainer.decodeIfPresent([String: Int].self, forKey: .distribution)
            
            self.follows = try container.decode(Int.self, forKey: .follows)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.follows = try container.decode(Int.self, forKey: .follows)
            
            let ratingContainer = try container.nestedContainer(keyedBy: RatingCodingKeys.self, forKey: .rating)
            self.average = try ratingContainer.decodeIfPresent(Double.self, forKey: .average)
            self.bayesian = try ratingContainer.decodeIfPresent(Double.self, forKey: .bayesian)
            self.distribution = try ratingContainer.decodeIfPresent([String: Int].self, forKey: .distribution)
            
            if let commentsContainer = try? container.nestedContainer(keyedBy: CommentsCodingKeys.self, forKey: .comments) {
                self.threadId = try commentsContainer.decodeIfPresent(Int.self, forKey: .threadId)
                self.repliesCount = try commentsContainer.decodeIfPresent(Int.self, forKey: .repliesCount)
            } else {
                self.threadId = nil
                self.repliesCount = nil
            }
        }
    }
}
