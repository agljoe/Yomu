//
//  UpdatesViewModel.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-06-18.
//

import Foundation
import MangaDexAPIKit
import Observation


/// A class used to encapsulate the data returned when fetching a users followed manga feed.
@MainActor @Observable
class UpdatesViewModel {
    /// All new "updates" for a users followed manga.
    ///
    /// Fetched updates are only a colleciton of chapters, but other data has been added to improve the interface and navigation experience.
    private(set) var updates: [Update] = []
    
    /// A dictionary where the key is a manga's UUID, and the value is the UUIDs of all chapters that have been
    /// marked read.
    private(set) var readMarkers: [String: [String]] = [:]
    
    /// Indicates if this model is currently fetching data from the MangaDexAPI.
    private(set) var isLoading: Bool = false
    
    /// The starting index of the collection to be fetched.
    ///
    /// ### See Also
    /// [Pagnation](https://api.mangadex.org/docs/01-concepts/pagination/)
    private var offset = 0
    
    /// Replaces the current updates with most recently available ones.
    func refreshUpdates() async throws {
        self.updates = []
        self.readMarkers = [:]
        self.offset = 0
        try await fetchUpdates()
    }
    
    /// Fetches the necesary data to display a list of a users updates.
    ///
    /// This function will fetch the first 25, then fetch 100 for all consecutive calls after that.
    ///
    /// - Note: All requests are encapsulated in this function to avoid data races.
    func fetchUpdates() async throws {
        guard !self.isLoading && UserDefaults.standard.bool(forKey: "isLoggedIn") else { return }
        defer { self.isLoading = false }
        self.isLoading = true
        
        let (chapters, _, _) = try await getChapters(limit: self.offset == 0 ? 25 : 100, offset: self.offset)
        let parentManga = chapters.map { $0.parentManga!.id }.removingDuplicates()
        
        async let covers = getCovers(ids: parentManga, limit: parentManga.count)
        async let (manga, _, _) = getParentManga(ids: parentManga, limit: parentManga.count)
        
        let groupedChapters = Dictionary(grouping: chapters, by: { $0.parentManga!.id })
        
        for (key, value) in groupedChapters {
            self.updates.append(Update(chapters: value, cover: try await covers.first(where: { $0.1 == key })!.0, manga: try await manga.first(where: { $0.id == key })!))
        }
        
        self.offset += 100
        self.updates.sort(by: >)
    }
    
    private func getChapters(limit: Int, offset: Int) async throws -> ([Chapter], Int, Int) {
        try await MangaDexAPIClient.shared.getFollowedFeed(limit: limit == 0 ? 25 : 100, offset: offset).get()
    }
    
    private func getCovers(ids: [UUID], limit: Int) async throws -> [(Cover, UUID)] {
        try await MangaDexAPIClient.shared.getCovers(for: ids, limit: limit).get()
    }
    
    private func getParentManga(ids: [UUID], limit: Int) async throws -> ([Manga], Int, Int) {
        try await MangaDexAPIClient.shared.getManga(ids, limit: limit).get()
    }
}
