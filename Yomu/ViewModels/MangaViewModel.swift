//
//  MangaViewModel.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-06-18.
//

import Foundation
import MangaDexAPIKit
import Observation

///
@MainActor @Observable
class MangaViewModel {
    var manga: Manga
    private(set) var chapters: [String: [Chapter]] = [:]
    private(set) var readMarkers: [String] = []
    private(set) var statistics: MangaStatistics = .init()
    private(set) var isLoading: Bool = false
    
    init(manga: Manga) {
        self.manga = manga
    }
    
    func fetchManga() async throws {
        guard !isLoading else { return }
        defer { isLoading = false }
        isLoading = true
        
        /// Use a copy of self.id to avoid data races.
        let id = self.manga.id
        
        async let chapters = fetchChapters(for: id)
        async let readMarkers = getReadMarkers(for: id)
        async let readingStatus = getReadingStatus(for: id)
        async let followed = getFollowedStatus(for: id)
//        async let statistics = getStatistics(for: id)
        
        self.chapters = Dictionary(grouping: try await chapters, by: { $0.volume ?? "No Volume" })
        self.readMarkers = try await readMarkers
        self.manga.readingStatus = ReadingStatus(rawValue: try await readingStatus)!
        self.manga.isFollowed = try await followed
//        self.statistics = try await statistics
    }
    
    private func fetchChapters(for manga: UUID) async throws -> [Chapter] {
        try await MangaDexAPIClient.shared.getAllChapters(for: manga).get()
    }
    
    private func getReadMarkers(for manga: UUID) async throws -> [String] {
        try await MangaDexAPIClient.shared.getReadMarker(manga).get()
    }
    
    private func getReadingStatus(for manga: UUID) async throws -> String {
        try await MangaDexAPIClient.shared.getReadingStatus(for: manga).get()
    }
    
    private func getFollowedStatus(for manga: UUID) async throws -> Bool {
        try await MangaDexAPIClient.shared.checkIfMangaIsFollowed(manga).get()
    }
    
    private func getStatistics(for manga: UUID) async throws -> MangaStatistics {
        try await MangaDexAPIClient.shared.getStatistics(for: manga).get()
    }
}
