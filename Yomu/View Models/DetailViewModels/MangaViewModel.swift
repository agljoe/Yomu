//
//  MangaViewModel.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-06-18.
//

import Foundation
import MangaDexData
import MangaDexAPIKit
import Observation

/// A class that hadles all data updates for a `PersistentManga` presented in a `MangaView`.
@MainActor @Observable
class MangaViewModel {
    /// The manga being displayed.
    var manga: PersistentManga
    
    var readingStatus: ReadingStatus
    
    /// The chapters of the persistent manga grouped by volume.
    var chapters: [String: [PersistentChapter]] = [:]
    
    /// A dictionary where the key is the volume for the respective cover.
    private(set) var covers: [String: PersistentCover] = [:]
    
    /// The latest released volume of a manga.
    private(set) var latestVolume: String = ""
    
    /// The names of all authors and artists joined in a list separated by commas.
    private(set) var formattedAuthorNames: String
    
    /// The statistics of the presented manga.
    private(set) var statistics: MangaStatistics = .init()
    
    /// Indicates if this model is currently fetching data from the MangaDexAPI.
    private(set) var isLoading: Bool = false
    
    /// Formats the `updateAt` member of a `PersistentChapter` so it can
    /// be passed in the `updateAtSince` query parameter.
    private let dateFormatter: DateFormatter
    
    
    /// Creates a new `MangaViewModel` with the specified `PersistentManga`.
    ///
    /// - Parameter manga: a `PersistentManga` to display.
    ///
    /// - Returns: a newly created `MangaViewModel` initalized with the specified manga, and an
    ///            RFC3339 style date formatter.
    init(manga: PersistentManga) {
        self.manga = manga
        self.readingStatus = ReadingStatus(rawValue: manga.readingStatus) ?? .none
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        RFC3339DateFormatter.timeZone = TimeZone(identifier: "UTC")
        self.dateFormatter = RFC3339DateFormatter
        
        self.formattedAuthorNames = manga.authors?.map { $0.name }.formatted(.list(type: .and, width: .short)) ?? ""
        
        let volumes : [String: [PersistentChapter]] = Dictionary(
            grouping: self.manga.chapters,
            by: { $0.volume ?? "No Volume" }
        )
        
        for (volume, chapters) in volumes {
            self.chapters[volume] = chapters.sorted { Double($0.number ?? "0") ?? 0 > Double($1.number ?? "0") ?? 0 }
        }
        
        for cover in self.manga.covers.sorted(by: { Double($0.volume ?? "0") ?? 0 > Double($1.volume ?? "0") ?? 0 }) {
            self.covers[cover.volume ?? "No Volume"] = cover
        }
        
        self.latestVolume = covers.keys.sorted(using: String.Comparator(options: [.diacriticInsensitive, .caseInsensitive, .numeric], order: .reverse)).first ?? "No Volume"
    }
    
    /// Returns the total number of chapters, may include chapters with duplicate numbers.
    ///
    /// Duplicate chatpers do not have the same UUID.
    var totalChapters: Int {
        chapters.reduce(0, { $0 + $1.value.count })
    }
    
    /// Returns the total number of volumes, any group of chapters with no volume
    /// is also considered a volume.
    var totalVolumes: Int {
        chapters.keys.count
    }
    
    var orderedVolumes: [String] {
        covers.keys.sorted(using: String.Comparator(options: [.diacriticInsensitive, .caseInsensitive, .numeric], order: .reverse))
    }
    
    var orderedChapters: [String] {
        chapters.keys.sorted(using: String.Comparator(options: [.diacriticInsensitive, .caseInsensitive, .numeric], order: .reverse))
    }
    
    /// Fetches new data related to this model's manga.
    ///
    /// - Throws: an associated `MangaDexAPIError` if any of the fetch operations fail.
    func updateManga() async throws {
        guard !isLoading else { return }
        defer { isLoading = false }
        isLoading = true
        
        /// Use a copy of self.id to avoid data races.
        let id = self.manga.id
        
        async let readingStatus: String = getReadingStatus(for: id)
        async let followed: Bool = getFollowedStatus(for: id)
        async let statistics: MangaStatistics = getStatistics(for: id)
        
        try await fetchChapters(for: id)
        
        let volumes: [String: [PersistentChapter]] = Dictionary(
            grouping: self.manga.chapters,
            by: { $0.volume ?? "No Volume" }
        )
        
        for (volume, chapters) in volumes {
            self.chapters[volume] = chapters.sorted { Double($0.number ?? "0") ?? 0 > Double($1.number ?? "0") ?? 0 }
        }
        
        self.manga.readingStatus = try await readingStatus
        self.readingStatus = ReadingStatus(rawValue: manga.readingStatus) ?? .none
        self.manga.isFollowed = try await followed
        self.statistics = try await statistics
    }
    
    /// Fetches all chapters uploaded after the most recent store chatper.
    ///
    /// - Parameter manga: the UUID of the manga whose chapters are being retrieved.
    ///
    /// - Throws: an associated `MangaDexAPIError` if any of the fetch operations fail.
    private func fetchChapters(for manga: UUID) async throws {
        var newChapters: [Chapter] = [Chapter]()
        
        if let latestChapter = self.manga.chapters.first {
            let lastUpdate = latestChapter.updatedAt
            
            guard Date(timeInterval: 60 * 60 * 12, since: lastUpdate) < Date() else { return }
            
            newChapters = try await MangaDexAPIClient.shared.getAllChapters(
                for: manga,
                filteredBy: [URLQueryItem(name: "updatedAtSince", value: dateFormatter.string(from: lastUpdate))]
            ).get()
        } else {
            newChapters = try await MangaDexAPIClient.shared.getAllChapters(for: manga).get()
        }
        
        guard !newChapters.isEmpty else { return }
        
        /// Fixes UI duplicates bug.
        let readMarkers: [String] = try await getReadMarkers(for: manga)
        let existingChapters: [UUID] = self.manga.chapters.map { $0.id }
        newChapters.removeAll { existingChapters.contains($0.id) }
        
        guard !newChapters.isEmpty else { return }
        
        try await SharedLibraryDatabase.shared.addChapters(newChapters, for: manga, with: readMarkers)
    }
    
    /// Retrieves the read markers for all chapters of a manga.
    ///
    /// - Parameter manga: the UUID of the manga whose chapter read markers are being retrieved.
    ///
    /// - Returns: an array of containing the UUID strings of all chatpers that have been read.
    ///
    /// - Throws: an associated `MangaDexAPIError` if any of the fetch operations fail.
    private func getReadMarkers(for manga: UUID) async throws -> [String] {
        try await MangaDexAPIClient.shared.getReadMarker(manga).get()
    }
    
    /// Retrieves the reading status of the displayed manga.
    ///
    /// - Parameter manga: the UUID of the manga to retrieve the reading status of.
    ///
    /// - Returns: a string that is a raw value of the enum `ReadingStatus`
    ///
    /// - Throws: an associated `MangaDexAPIError` if any of the fetch operations fail.
    private func getReadingStatus(for manga: UUID) async throws -> String {
        try await MangaDexAPIClient.shared.getReadingStatus(for: manga).get()
    }
    
    /// Retrieves the followed status of the displayed manga.
    ///
    /// - Parameter manga: the UUID of the manga to retrieve the followed status of.
    ///
    /// - Returns: true if the specified manga is followed.
    ///
    /// - Throws: an associated `MangaDexAPIError` if any of the fetch operations fail.
    private func getFollowedStatus(for manga: UUID) async throws -> Bool {
        try await MangaDexAPIClient.shared.checkIfMangaIsFollowed(manga).get()
    }
    
    /// Retrieves the available statistics of the displayed manga.
    ///
    /// - Parameter manga: the UUID of the manga to retrieve the statistics  of.
    ///
    /// - Returns: a `MangaStatistics` value containing the rating, follows count, and comments thread ID.
    ///
    /// - Throws: an associated `MangaDexAPIError` if any of the fetch operations fail.
    private func getStatistics(for manga: UUID) async throws -> MangaStatistics {
        try await MangaDexAPIClient.shared.getStatistics(for: manga).get()
    }
    
//    @discardableResult
//    private func updateReadingStatus(to readingStatus: ReadingStatus) async throws -> Response {
//        try await MangaDexAPIClient.shared.updateReadingStatus(for: self.manga.id, to: readingStatus).get()
//    }
    
    func setFollowedStatus(to newStatus: Bool) async -> Bool {
        do {
            switch newStatus {
            case true:
                let _ = try await MangaDexAPIClient.shared.follow(manga: self.manga.id).get()
            case false:
                let _ = try await MangaDexAPIClient.shared.unfollow(manga: self.manga.id).get()
            }
            return true
        } catch {
            return false
        }
    }
    
    /// Finds the image URL for up to the first five volumes of the displayed manga.
    ///
    /// - Returns: an array containing all available image URLs with a resolution of 512 pixels.
    func getCoverDisplayURLs() -> [URL] {
        var covers: [URL] = [URL]()
        
        for i in 1...5 {
            if let cover = self.covers["\(i)"] {
                covers.append(cover.imageURL512)
            }
        }
        
        return covers
    }
    
    /// Trunicates the trailing decimals of a double.
    ///
    /// - Returns: The bayesian average rating of a manga formatted to two decimal places.
    func formattedRating() -> String {
        return "\(String(format: "%.2f", self.statistics.bayesian ?? 0.0))(\(self.statistics.totalRatings()))"
    }
}
