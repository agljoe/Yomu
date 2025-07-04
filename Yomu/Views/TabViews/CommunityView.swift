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
                            let manga = try await MangaDexAPIClient.shared.getManga(UUID(uuidString: "0e8fac17-979e-4e37-8f45-2c334b25d6dd")!).get()
                            try await SharedLibraryDatabase.shared.insert(manga: manga)
                            try await SharedLibraryDatabase.shared.database.save()
                        }
                    }
                }
                
                Section {
                    Button("Test Inserting") {
                        Task {
                            do {
                                try await addManga()
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Reset Library", role: .destructive) {
                        Task {
                            try! await database.delete(Selector<PersistentManga>.Delete.all)
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
//    
//    print(manga)
    
    for title in manga {
        do {
            try await SharedLibraryDatabase.shared.insert(manga: title)
        } catch let error {
            print(title)
            print(error)
        }
    }
}

#Preview {
    CommunityView()
}
