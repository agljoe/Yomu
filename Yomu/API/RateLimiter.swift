//
//  RateLimiter.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-29.
//

import Foundation

/// A manager that ensures the number of requests made by the `MangaDexAPIRequestManger` does not exceed the specified rate limits.
///
/// ### See Also:
/// [Limitations and Requirements](https://api.mangadex.org/docs/2-limitations/)
struct RateLimiter: Sendable {
    /// The last time an API call was made
    private var lastRequestDate: Date?
    
    /// The maximum number of API calls that can be made at a certain endpoint
    ///  on a given time interval.
    private let limit: Int
    
    /// The period of time for which a maximum number of API can be made.
    private let interval: TimeInterval
    
    /// The number of API calls made over a given period of time.
    private var requests: Int = 0
    
    /// Creates a new `RateLimiter` instance that restricts the the number of API calls
    /// that will be executed to the given limit over the given time interval.
    ///
    /// - Parameters:
    ///     - limit: an amount of requests to a 3rd party API.
    ///     - interval:  a period of time in seconds.
    ///
    /// - Returns: a newly created `RateLimier` whose rate limit is defined as `limit` per `timeInterval`.
    public init(limit: Int, interval: TimeInterval) {
        self.limit = limit
        self.interval = interval
    }
    
    /// Determines if an API call can be made within the current rate limit.
    ///
    /// - Returns: true if the request can be made, false otherwise.
    mutating func canMakeRequest() -> Bool {
        let timestamp = Date.now
        if let lastRequestDate = lastRequestDate {
            return timestamp.timeIntervalSince(lastRequestDate) < interval ? requests < limit ? increment() : false : reset(whereLastRequestDate: timestamp)
        } else {
            lastRequestDate = timestamp
            return increment()
        }
    }
    
    /// Increases the number of requests by one.
    ///
    /// - Returns: true
    private mutating func increment() -> Bool {
        requests += 1
        return true
    }
    
    /// Resets the number of requests to 1, and the last request date to be time of the most recent request.
    ///
    /// - Parameter date: the time at which the most recent API request took place.
    ///
    /// - Returns: true
    private mutating func reset(whereLastRequestDate date: Date) -> Bool {
        lastRequestDate = date
        requests = 1
        return true
    }
}

