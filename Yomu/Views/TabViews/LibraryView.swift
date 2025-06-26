//
//  LibraryView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import MangaDexData
import MangaDexAPIKit
import SwiftData
import SwiftUI

struct LibraryView: View {
    @Environment(\.database) var database
    @Query(sort: \PersistentManga.readingStatus) var library: [PersistentManga]
//    @State private var model = Model()
    
    let colums = Array(repeating: GridItem(.flexible()), count: UserDefaults.standard.integer(forKey: "columns") < 2 ? 2 : UserDefaults.standard.integer(forKey: "columns"))
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: colums) {
                    ForEach(library) { manga in
                        CachedAsyncImage(url: manga.coverURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .navigationTitle(Text("Library"))
        }
        .searchable(text: .constant(""))
//        .refreshable { Task { try? await model.updateLibrary() } }
    }
}

//extension LibraryView {
//    @MainActor @Observable
//    class Model {
//        private(set) var isLoading: Bool = false
//        
//        func updateLibrary() async throws {
//            guard !isLoading else { return }
//            defer { isLoading = false }
//            isLoading = true
////            async let idsToUpdate = SharedLibraryDatabase.shared.getIdsToUpdate()
////            async let idsToInsert = getIdsToInsert()
//            
//            
//        }
//        
//        private func getIdsToInsert() async throws -> [String: String] {
//            try await MangaDexAPIRequestManager.shared.getAllReadingStatus()
//        }
//        
//        private func updateManga(_ ids: [UUID]) async throws {
//            guard !ids.isEmpty else { return }
//            let requestsToMake = ids.count > 100 ? (ids.count / 100) + 1 : 1
//            
//            var titles = [Manga]()
//            
//            for i in 0...requestsToMake {
//                async let (newManga, _, _) = MangaDexAPIRequestManager.shared.getManga(Array(ids[(i - 1) * 100..<(i * 100 > ids.count ? ids.count : i * 100)]), limit: i * 100)
//                titles.append(contentsOf: try await newManga)
//            }
//            
//            let mangaToUpdate = titles
//            assert(mangaToUpdate.count == titles.count)
//        }
//        
//        private func insertManga(_ manga: [String: String]) async throws {
//            let ids = manga.keys.map { UUID(uuidString: $0)! }
//            guard !ids.isEmpty else { return }
//            let requestsToMake = ids.count > 100 ? (ids.count / 100) + 1 : 1
//            
//            var titles = [Manga]()
//            
//            for i in 1...requestsToMake {
//                async let (newManga, _, _) = MangaDexAPIRequestManager.shared.getManga(Array(ids[(i - 1) * 100..<(i * 100 > ids.count ? ids.count : i * 100)]), limit: i * 100)
//                titles.append(contentsOf: try await newManga)
//            }
//            
//            let mangaToInsert = titles
//            assert(mangaToInsert.count == titles.count)
//            
//            try await SharedLibraryDatabase.shared.database.transaction { modelContext in
//                for title in mangaToInsert {
//                    modelContext.insert(StoredManga.init(from: title, readingStatus: ReadingStatus(rawValue: manga[title.id.uuidString] ?? "none")))
//                }
//            }
//            
//            try await SharedLibraryDatabase.shared.database.save()
//        }
//    }
//}

#Preview {
    LibraryView()
}
