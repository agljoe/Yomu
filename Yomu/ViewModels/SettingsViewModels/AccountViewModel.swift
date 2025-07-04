//
//  AccountViewModel.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-06-18.
//

import Foundation
import MangaDexData
import MangaDexAPIKit
import Observation

@MainActor @Observable
class AccountViewModel {
    var credentials: Credentials = Credentials()
    private(set) var isLoading: Bool = false
    
    func setup() async throws {
        guard !isLoading && UserDefaults.standard.bool(forKey: "isLoggedIn") else { return }
        defer { isLoading = false }
        isLoading = true
        let ids = try await getLibrary()
        
        //            if let reading = ids[ReadingStatus.reading.rawValue] {
        //                try await loadTitles(ids: reading, status: .reading)
        //            }
        
        //            if let onHold = ids[ReadingStatus.on_hold.rawValue] {
        //                try await loadTitles(ids: onHold , status: .on_hold)
        //            }
        
        //            if let dropped = ids[ReadingStatus.dropped.rawValue] {
        //                try await loadTitles(ids: dropped, status: .dropped)
        //            }
        
        if let planToRead = ids[ReadingStatus.plan_to_read.rawValue] {
            try await loadTitles(ids: planToRead, status: .plan_to_read)
        }
        
        //            if let completed = ids[ReadingStatus.completed.rawValue] {
        //                try await loadTitles(ids: completed, status: .completed)
        //            }
        
        //            try await SharedLibraryDatabase.shared.database.save()
    }
    
    func login() async throws {
        guard !isLoading && !UserDefaults.standard.bool(forKey: "isLoggedIn") else { return }
        defer { isLoading = false }
        isLoading = true
        

        UserDefaults.standard.set(Rating.pornographic.rawValue, forKey: "contentRating")

        
        let _ = try await MangaDexAPIClient.shared.login(with: self.credentials).get()
        
    }
    
    func reauthenticate() async throws {
        guard !isLoading && UserDefaults.standard.bool(forKey: "isLoggedIn") else { return }
        defer {  isLoading = false }
        isLoading = true
        let _ = try await MangaDexAPIClient.shared.reauthenticate().get()
    }
    
    private func getLibrary() async throws -> [String: [UUID]] {
        async let statuses = MangaDexAPIClient.shared.getAllReadingStatus().get()
        let mapped: [(UUID, String)] = try await statuses.map { (UUID(uuidString: $0.0)!, $0.1) }
        let grouped = Dictionary(grouping: mapped, by: { $0.1 })
        var result = [String: [UUID]]()
        for (key, value) in grouped { result[key] = value.map(\.0) }
        return result
    }
    
    private func loadTitles(ids: [UUID], status: ReadingStatus) async throws {
        guard !ids.isEmpty else { return }
        
        let manga = try await MangaDexAPIClient.shared.getManga(ids).get()
    
        for title in manga {
            await SharedLibraryDatabase.shared.database.insert { PersistentManga(from: title, readingStatus: status) }
        }
        
        
        try await SharedLibraryDatabase.shared.database.save()
    
        print("inserted")
    }
}
