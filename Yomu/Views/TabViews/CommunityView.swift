//
//  CommunityView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import DataThespian
import MangaDexData
import MangaDexAPIKit
import SwiftUI

struct CommunityView: View {
    @Environment(\.database) var database
    var body: some View {
        VStack {
            Form {
                Section {
                    Button("Insert One") {
                        Task {
                            do {
                                let manga = try await MangaDexAPIClient.shared.getManga(UUID(uuidString: "a44afe37-24fd-44b8-874e-17e8a24ca3ca")!).get()
                                let (covers, _, _) = try await MangaDexAPIClient.shared.getCovers(mangaIDs: [manga.id], locale: "ja").get()
                                try await SharedLibraryDatabase.shared.insert(manga: manga, with: covers)
                                try await SharedLibraryDatabase.shared.database.save()
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Insert Another") {
                        Task {
                            do {
                                let manga = try await MangaDexAPIClient.shared.getManga(UUID(uuidString: "1ee97895-4796-4bcf-bcd1-5ef99c011f8b")!).get()
                                let (covers, _, _) = try await MangaDexAPIClient.shared.getCovers(mangaIDs: [manga.id], limit: 100, locale: "ja").get()
                                try await SharedLibraryDatabase.shared.insert(manga: manga, with: covers)
                                try await SharedLibraryDatabase.shared.database.save()
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Test Inserting") {
//                        Task {
//                            do {
//                                try await addManga()
//                            } catch let error {
//                                print(error)
//                            }
//                        }
                        print("coming soon")
                    }
                }
                
                Section {
                    Button("Reset Library", role: .destructive) {
                        Task {
                            do {
                                try await SharedLibraryDatabase.shared.database.delete(.all(PersistentManga.self))
                                try await SharedLibraryDatabase.shared.database.delete(.all(PersistentAuthor.self))
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                }
            }
        }
    }
}

private func getOnHoldIds() async throws -> [UUID] {
    async let statuses = MangaDexAPIClient.shared.getAllReadingStatus().get()
    let mapped: [(UUID, String)] = try await statuses.map { (UUID(uuidString: $0.0)!, $0.1) }
    let grouped = Dictionary(grouping: mapped, by: { $0.1 })
    var result = [String: [UUID]]()
    for (key, value) in grouped { result[key] = value.map(\.0) }
    return result[ReadingStatus.on_hold.rawValue]!
}

private func addManga() async throws {
    let ids = try await getOnHoldIds()
    print(ids)
    
    let manga = try await MangaDexAPIClient.shared.getManga(ids).get()
    
    for title in manga {
        do {
            let (covers, _, _) = try await MangaDexAPIClient.shared.getCovers(mangaIDs: [title.id], locale: title.originalLanguage).get()
            try await SharedLibraryDatabase.shared.insert(manga: title, with: covers)
        } catch let error {
            print(title)
            print(error)
        }
    }
}

#Preview {
    CommunityView()
}
