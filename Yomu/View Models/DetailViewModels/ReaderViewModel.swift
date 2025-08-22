//
//  ReaderViewModel.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-06-18.
//

import Foundation
import MangaDexData
import MangaDexAPIKit
import Observation


@MainActor @Observable
class ReaderViewModel {
    private(set) var chapter: PersistentChapter
    private(set) var atHomeComponents: AtHomeChapterComponents = AtHomeChapterComponents()
    private(set) var isLoading: Bool = false
    
    var pageWidths = [CGFloat]()
    var pageHeights = [CGFloat]()
    
    init(chapter: PersistentChapter) {
        self.chapter = chapter
    }
    
    func fetchChapter() async throws {
        guard !self.isLoading else { return }
        defer { self.isLoading = false }
        self.isLoading = true
        
        let id = self.chapter.id
        
        async let compontents = getComponents(for: id)
        
        self.atHomeComponents = try await compontents
        self.pageWidths = Array(Array(repeating: CGFloat.zero, count: try await compontents.data.count))
        self.pageHeights = Array(Array(repeating: CGFloat.zero, count: try await compontents.data.count))
    }
    
    private func getComponents(for chapter: UUID) async throws -> AtHomeChapterComponents {
        try await MangaDexAPIClient.shared.getChapterComponents(for: chapter).get()
    }
}

