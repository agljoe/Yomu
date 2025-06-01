//
//  RequestManager.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-29.
//

import Foundation

/// A type that handle requests to a 3rd party API.
protocol RequestManager: Sendable {
    /// Enforces MangaDex's rate limit for all standard requests.
    var rateLimiter: RateLimiter { get set }
    
    /// Executes any request made by this manager.
    var requestExecutor: RequestExecutor { get }
    
    /// Executes some work on a given request executor.
    ///
    /// - Parameter body: a closure that uses a request executor to perform a block of asychronous work.
    ///
    /// - Throws: A `CancellationError` if the request is cancelled while waiting for the rate limiter.
    /// - Throws: Any error thrown by the body closure.
    mutating func withRequestExecutor(_ body: @escaping @Sendable (RequestExecutor) async throws -> Void) async throws
    
    /// Executes some work on a given request executor.
    ///
    /// - Parameter body: a closure that uses a request executor to perform a block of asychronous work and returns the result.
    ///
    /// - Returns: the result of the body closure.
    ///
    /// - Throws: A `CancellationError` if the request is cancelled while waiting for the rate limiter.
    /// - Throws: Any error thrown by the body closure.
    mutating func withRequestExecutor<T>(_ body: @escaping @Sendable (RequestExecutor) async throws -> T) async throws -> T
}

/// Provides default implementations for the `withRequestExecutor` methods.
extension RequestManager {
    mutating func withRequestExecutor(_ body: @escaping @Sendable (RequestExecutor) async throws -> Void) async throws {
        if !rateLimiter.canMakeRequest() { try await Task.sleep(for: .seconds(1)) }
        try await body(self.requestExecutor)
    }
    
    mutating func withRequestExecutor<T>(_ body: @escaping @Sendable (any RequestExecutor) async throws -> T) async throws -> T {
        if !rateLimiter.canMakeRequest() { try await Task.sleep(for: .seconds(1)) }
        return try await body(self.requestExecutor)
    }
}

/// A singleton that makes all requests to the MangaDexAPI.
public struct MangaDexAPIRequestManager: RequestManager {
    /// The shared instance of this request manager.
    public static let shared: MangaDexAPIRequestManager = .init()
    
    internal var rateLimiter: RateLimiter
    
    /// An endpont specific rate limiter for accessing chapter images.
    private var atHomeRateLimiter: RateLimiter
    
    internal let requestExecutor: RequestExecutor = MangaDexAPIRequestExecutor()
    
    /// Creates a new `MangaDexRequestManager` with the given rate limiters.
    ///
    /// - Parameters:
    ///     - rateLimiter: a rate limiter who enforces the standard global limit of 5 requests per second.
    ///     - atHomeRateLimiter: a rate limiter who enforces the at-home rate limit of 40 requests per second.
    ///
    /// - Returns: a newly created `MangaDexApiRequestManager` initialized with the given rate limits.
    private init(rateLimiter: RateLimiter = .init(limit: 5, interval: 1), atHomeRateLimiter: RateLimiter = .init(limit: 40, interval: 1)) {
        self.rateLimiter = rateLimiter
        self.atHomeRateLimiter = atHomeRateLimiter
    }
    
    /// Executes some work on a given request executor.
    ///
    /// - Parameter body: a closure that uses a request executor to perform a block of asychronous work and returns the result.
    ///
    /// - Returns: the result of the body closure.
    ///
    /// - Throws: A `CancellationError` if the request is cancelled while waiting for the rate limiter.
    /// - Throws: Any error thrown by the body closure.
    mutating func withAtHomeRequestExecutor<T>(_ body: @escaping @Sendable (RequestExecutor) async throws -> T) async throws -> T {
        if !atHomeRateLimiter.canMakeRequest() { try await Task.sleep(for: .seconds(1)) }
        return try await body(self.requestExecutor)
    }
}

/// Authentication requests.
extension MangaDexAPIRequestManager {
    mutating func login(with credentials: Credentials) async throws {
        try await self.withRequestExecutor { try await $0.execute(request: LoginRequest(credentials: credentials)) }
    }
    
    mutating func reauthenticate() async throws {
        try await self.withRequestExecutor { try await $0.execute(request: ReAuthenticationRequest()) }
    }
}

/// Author and artist requests.
extension MangaDexAPIRequestManager {
    /// Retrieves the author or artist with the given ID.
    ///
    /// - Parameter id: the UUID of an author or artist.
    ///
    /// - Returns: the retrieved author or artist.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getAuthor(_ id: UUID) async throws -> Author {
        try await self.withRequestExecutor { try await $0.execute(request: Request<AuthorEntity>(.init(id: id))) }
    }
    
    /// Retrieves the authors or artists with the given IDs.
    ///
    /// - Parameters:
    ///     - ids: the UUIDs of some authors or artists.
    ///     - limit: the maximum amount of authors or artists to retrieve.
    ///     - offset: an amount to shift the retrieved collection's index.
    ///
    /// - Returns: an array of authors or artists, the total size of the collection, and its offset.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getAuthors(_ ids: [UUID], limit: Int? = nil, offset: Int? = nil) async throws -> ([Author], Int, Int)  {
        try await self.withRequestExecutor { try await $0.execute(request: ListRequest<AuthorListEntity>(.init(ids: ids, limit: limit ?? 100, offset: offset ?? 0))) }
    }
}

/// Chapter requests.
extension MangaDexAPIRequestManager {
    /// Retrieves the chapter with the given ID.
    ///
    /// - Parameter id: the UUID of a chapter.
    ///
    /// - Returns: the retrieved chapter.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getChapter(_ id: UUID) async throws -> Chapter {
        try await self.withRequestExecutor { try await $0.execute(request: Request<ChapterEntity>(.init(id: id))) }
    }
    
    /// Retrieves the chapters with the given IDs.
    ///
    /// - Parameters:
    ///     - ids: the UUIDs of some chapters.
    ///     - limit: the maximum amount of chapters to retrieve.
    ///     - offset: an amount to shift the retrieved collection's index.
    ///
    /// - Returns: an array of chapters, the total size of the collection, and its offset.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getChapters(_ ids: [UUID], limit: Int? = nil, offset: Int? = nil) async throws -> ([Chapter], Int, Int)  {
        try await self.withRequestExecutor { try await $0.execute(request: ListRequest<ChapterListEntity>(.init(ids: ids, limit: limit ?? 100, offset: offset ?? 0))) }
    }
    
    /// Retrieves the at home chapter compontents for the given chapter.
    ///
    /// - Parameter id: the UUID of a chapter.
    ///
    /// - Returns: the retrieved chapter components.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getChapterComponents(_ id: UUID) async throws -> AtHomeChapterComponents {
        try await self.withAtHomeRequestExecutor { try await $0.execute(request: AtHomeRequest(for: id)) }
    }
}

/// Chapter statistics requests.
extension MangaDexAPIRequestManager {
    /// Retrieves the comments count for the given chatper.
    ///
    /// - Parameter chapter: the UUIDs of a chapter.
    ///
    /// - Returns: the retrieved statistics.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getStatistics(for chapter: UUID) async throws -> ChapterStatistics {
        try await self.withRequestExecutor { try await $0.execute(request: ChapterStatisticsRequest(for: chapter)) }
    }
    
    /// Retrieves the comments count for the given chatpers.
    ///
    /// - Parameter chapters: the UUIDs of some chapters.
    ///
    /// - Returns: a dictionary conataining the statistics for the given chatpers, where the key is a chapter's UUID string.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getStatistics(for chapters: [UUID]) async throws -> [String: ChapterStatistics] {
        try await self.withRequestExecutor { try await $0.execute(request: GroupedChapterStatisticsRequest(ids: chapters)) }
    }
}

/// Cover requests.
extension MangaDexAPIRequestManager {
    /// Retrieves the cover with the given ID.
    ///
    /// - Parameter id: the UUID of a cover.
    ///
    /// - Returns: the retrieved chapter.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getCover(_ id: UUID) async throws -> Cover {
        try await self.withRequestExecutor { try await $0.execute(request: Request<CoverEntity>(.init(id: id))) }
    }
    
    /// Retrieves the cover with the given IDs.
    ///
    /// - Parameters:
    ///     - ids: the UUIDs of some cover.
    ///     - limit: the maximum amount of covers to retrieve.
    ///     - offset: an amount to shift the retrieved collection's index.
    ///
    /// - Returns: an array of covers, the total size of the collection, and its offset.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getCovers(coverIDs ids: [UUID], limit: Int? = nil, offset: Int? = nil) async throws -> ([Cover], Int, Int)  {
        try await self.withRequestExecutor { try await $0.execute(request: ListRequest<CoverListEntity>(.init(coverIDs: ids, limit: limit ?? 10, offset: offset ?? 0))) }
    }
    
    /// Retrieves all covers for the given manga.
    ///
    /// - Parameters:
    ///     - ids: the UUIDs of some manga.
    ///     - limit: the maximum amount of covers to retrieve.
    ///     - offset: an amount to shift the retrieved collection's index.
    ///
    /// - Returns: an array of covers, the total size of the collection, and its offset.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getCovers(mangaIDs ids: [UUID], limit: Int? = nil, offset: Int? = nil) async throws -> ([Cover], Int, Int)  {
        try await self.withRequestExecutor { try await $0.execute(request: ListRequest<CoverListEntity>(.init(mangaIDs: ids, limit: limit ?? 10, offset: offset ?? 0))) }
    }
    
    /// Retrieves the latest coversfor the given manga.
    ///
    /// - Parameters:
    ///     - ids: the UUIDs of some manga.
    ///     - limit: the maximum amount of covers to retrieve.
    ///     - offset: an amount to shift the retrieved collection's index.
    ///
    /// - Returns: an array of covers, the total size of the collection, and its offset.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getCovers(for ids: [UUID], limit: Int? = nil, offset: Int? = nil) async throws -> ([Cover], Int, Int)  {
        try await self.withRequestExecutor { try await $0.execute(request: ListRequest<CoverFromMangaListEntity>(.init(ids: ids, limit: limit ?? 10, offset: offset ?? 0))) }
    }
}

/// Chapter feed requests.
extension MangaDexAPIRequestManager {
    /// Retrieves a list of the most recently updated chapters for all manga in the specified MDList.
    ///
    /// - Parameters:
    ///     - id: the UUID  of the MDList to fetch chapters from.
    ///     - limit: the maximum number of chapters to retrieve.
    ///     - offset: an amount to shift the retrieved collection's index.
    ///
    /// - Returns: an array of chapters, the size of the collection, and its offset.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getCustomFeed(_ id: UUID, limit: Int? = nil, offset: Int? = nil) async throws -> ([Chapter], Int, Int) {
        try await self.withRequestExecutor { try await $0.execute(request: ListRequest<CustomFeedEntity>(.init(id: id, limit: limit ?? 100, offset: offset ?? 0))) }
    }
    
    /// Retrieves a list of the most recently updated chapters for all manga followed by a user.
    ///
    /// - Parameters:
    ///     - limit: the maximum number of chapters to retrieve.
    ///     - offset: an amount to shift the retrieved collection's index.
    ///
    /// - Returns: an array of chapters, the size of the collection, and its offset.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getFollowedFeed(limit: Int? = nil, offset: Int? = nil) async throws -> ([Chapter], Int, Int) {
        try await self.withRequestExecutor { try await $0.execute(request: ListRequest<FollowedFeedEntity>(.init(limit: limit ?? 100, offset: offset ?? 0))) }
    }
}

/// Follow requests
extension MangaDexAPIRequestManager {
    /// Determines if a user if following a given manga.
    ///
    /// - Parameter id: the UUID of manga.
    ///
    /// - Returns: true if the user follows the specifed manga, false otherwise.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func checkIfMangaIsFollowed(_ id: UUID) async throws -> Bool {
        try await self.withRequestExecutor { try await $0.execute(request: CheckIfMangaIsFollowedRequest(id: id)) }
    }
    
    /// Adds the specified manga's chapters to a user's followed feed.
    ///
    /// - Parameter id: the UUID of a manga.
    ///
    /// - Returns: a result indicating if the specified manga was successfully followed.
    mutating func follow(manga id: UUID) async -> Result<Response, Error> {
        do {
            async let result: Response = self.withRequestExecutor { try await $0.execute(request: Follow(manga: id)) }
            return .success(try await result)
        } catch let error {
            return .failure(error)
        }
    }
    
    /// Removes the specified manga's chapters to a user's followed feed.
    ///
    /// - Parameter id: the UUID of a manga.
    ///
    /// - Returns: a result indicating if the specified manga was successfully unfollowed.
    mutating func unfollow(manga id: UUID) async -> Result<Response, Error> {
        do {
            async let result: Response = self.withRequestExecutor { try await $0.execute(request: Unfollow(manga: id)) }
            return .success(try await result)
        } catch let error {
            return .failure(error)
        }
    }
}

/// Manga requests.
extension MangaDexAPIRequestManager {
    /// Retrieves the manga with the specified UUID.
    ///
    /// - Parameter id: the UUID of a manga.
    ///
    /// - Returns: the retrieved manga.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getManga(_ id: UUID) async throws -> Manga {
        try await self.withRequestExecutor { try await $0.execute(request: Request<MangaEntity>(.init(id: id))) }
    }
    
    /// Retrieves the magna with the spcified UUIDs.
    ///
    /// - Parameters:
    ///     - ids: the UUIDs of some manga.
    ///     - limit: the maximum number of manga to retrieve.
    ///     - offset: an amount to shift the retrieved collection's index.
    ///     
    /// - Returns: an array of manga, the size of the collection, and its offset.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getManga(_ ids: UUID, limit: Int? = nil, offset: Int? = nil) async throws -> ([Manga], Int, Int) {
        try await self.withRequestExecutor{ try await $0.execute(request: ListRequest<MangaListEntity>(.init(ids: ids, limit: limit ?? 100, offset: offset ?? 0))) }
    }
    
    /// Retrieves a random manga.
    ///
    /// - Returns: a manga that abides by a user's content prefernces.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getRandomManga() async throws -> Manga {
        try await self.withRequestExecutor { try await $0.execute(request: Request<RandomMangaEntity>(.init())) }
    }
    
    mutating func getChapters(for manga: UUID, limit: Int? = nil, offset: Int? = nil) async throws -> ([Chapter], Int, Int) {
        try await self.withRequestExecutor { try await $0.execute(request: ListRequest<MangaFeedEntity>(.init(id: manga, limit: limit ?? 100, offset: offset ?? 0))) }
    }
}

/// Manga statistics request.
extension MangaDexAPIRequestManager {
    /// Retrieves the ratings, comments and total follows of a manga.
    ///
    /// - Parameter manga: the UUID of a manga.
    ///
    /// - Returns: a `MangaStatisics` instance for the specified manga.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getStatistics(for manga: UUID) async throws -> MangaStatistics {
        try await self.withRequestExecutor { try await $0.execute(request: MangaStatisticsRequest(for: manga)) }
    }
    
    /// Retrieves the ratings, comments and total follows of some manga.
    ///
    /// - Parameter manga: the UUID of some manga.
    ///
    /// - Returns: a  dictionary containng a`MangaStatisics` instance for the specified manga, where the key is a manga's UUID string.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getStatisics(for manga: [UUID]) async throws -> [String: MangaStatistics] {
        try await self.withRequestExecutor { try await $0.execute(request: GroupedMangaStatisticsRequest(ids: manga)) }
    }
}

/// Tag requests.
extension MangaDexAPIRequestManager {
    /// Retrieves all available tags.
    ///
    /// - Returns: an array containing the currently available tags.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getTags() async throws -> [Tag] {
        try await self.withRequestExecutor { try await $0.execute(request: TagListRequest()) }
    }
}

/// Reading status requests.
extension MangaDexAPIRequestManager {
    /// Retrieves the user's current reading status for a given manga.
    ///
    /// - Parameter manga: the UUID of a manga.
    ///
    /// - Returns: a string describing the reading status for the specified manga.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getReadingStatus(for manga: UUID) async throws -> String {
        try await self.withRequestExecutor { try await $0.execute(request: MangaReadingStatusRequest(for: manga)) }
    }
    
    /// Retrieves all manga the user has set a reading status for.
    ///
    /// - Returns: A dictionary containing every manga reading status, where the key is a manga's UUID string.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getAllReadingStatus() async throws -> [String: String] {
        try await self.withRequestExecutor { try await $0.execute(request: AllMangaReadingStatusRequest()) }
    }
    
    /// Sets the reading status for a given manga.
    ///
    /// - Parameters:
    ///     - manga: the UUID of a manga.
    ///     - status: the status that given manga will be updated to.
    ///
    /// - Returns: a result indicating if the specifed manga's reading status was successfully updated/
    mutating func updateReadingStatus(for manga: UUID, to status: ReadingStatus) async -> Result<Response, Error> {
        do {
            let result: Response = try await self.withRequestExecutor { try await $0.execute(request: UpdateMangaReadingStatusRequest(for: manga, to: status)) }
            return .success(result)
        } catch let error {
            return .failure(error)
        }
    }
}

/// Scanlation group requests.
extension MangaDexAPIRequestManager {
    mutating func getScanlationGroup(_ id: UUID) async throws -> ScanlationGroup {
        try await self.withRequestExecutor { try await $0.execute(request: Request<ScanlationGroupEntity>(.init(id: id))) }
    }
}

/// Read marker requests.
extension MangaDexAPIRequestManager {
    /// Retrieves the UUIDs of all chapters that have been read for the given manga.
    ///
    /// - Parameter id: the UUID of a manga.
    ///
    /// - Returns: the UUID strings of all chapters that have been read.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getReadMarker(_ id: UUID) async throws -> [String] {
        try await self.withRequestExecutor { try await $0.execute(request: Request<ReadMarkerEntity>(.init(id: id))) }
    }
    
    /// Retrieves the UUIDs of all chapters that have been read for the given manga.
    ///
    /// - Parameter ids: the UUID of some manga.
    /// - Returns: a dictionary containing the UUID strings of all chapters that have been read, where the key is its parent manga's UUID string.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func getReadMarkers(_ ids: [UUID]) async throws -> [String: [String]] {
        try await self.withRequestExecutor { try await $0.execute(request: Request<ReadMarkerGroupEntity>(.init(ids: ids))) }
    }
    
    /// Sets the read markers of the chatpers for the specified manga.
    ///
    /// - Parameters:
    ///     - mangaID: the UUID of the manga the given chapters belong to.
    ///     - readChapters: the chapters whose read markers will be set to read.
    ///     - unreadChapters: the chapters whose read markers will be set to undread.
    ///
    /// - Throws: A `MangaDexAPIError` if the request returns without status code 200.
    mutating func updateReadMarkers(mangaID: UUID, readChapters: [UUID]? = nil, unreadChapters: [UUID]? = nil) async throws {
        try await self.withRequestExecutor { try await $0.execute(request: UpdateReadMarkerRequest(mangaID: mangaID, chapterIdsRead: readChapters, chapterIdsUnread: unreadChapters)) }
    }
}

