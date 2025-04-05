//
//  UpdatesView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import Foundation
import SwiftUI
//struct MangaUpdatesLogger {
//    var updates: [Update]
//    var limit: Int
//    var offset: Int
//    var total: Int
//    var latestUpdate: Date
//    
//    init(updates: [Update], limit: Int, offset: Int, total: Int, latestUpdate: Date) {
//        self.updates = updates
//        self.limit = limit
//        self.offset = offset
//        self.total = total
//        self.latestUpdate = latestUpdate
//    }
//}
//
//struct ChapterListView: View {
//    @State var chapters: [Chapter]
//    
//    var body: some View {
//        List(chapters) { chapter in
//            Section {
//                NavigationLink {
//                    // TODO: link to external website if chapter has externalLink
//                    ReaderView(chapterId: chapter.id, title: "Ch. \(chapter.chapter ?? "0") \(chapter.title ?? "")")
//                        .navigationBarBackButtonHidden(true)
//                } label: {
//                    HStack {
//                        LazyVStack(alignment: .center) {
//                            Image(systemName: chapter.hasBeenRead ? "eye.slash" : "eye")
//                            Image(systemName: "person.3")
//                        }
//                        
//                        VStack(alignment: .leading) {
//                            Text("\(chapter.volume != nil ? "Vol. \(chapter.volume ?? "0")" : "") Ch. \(chapter.chapter ?? "0") \(chapter.title ?? "")")
//                                .lineLimit(1)
//                            Text(chapter.scanlationGroup?.name ?? "No group")
//                                .lineLimit(1)
//                        }
//                    }
//                }
//            }
//            .listRowBackground(Color.clear)
//        }
//        .scrollIndicators(.never)
//        .listStyle(.plain)
//        .scrollContentBackground(.hidden)
//    }
//}
//
//struct MangaUpdateView: View {
//    @State var update: Update
//    
//    var body: some View {
//            VStack(alignment: .leading) {
//                Text(update.chapters.first!.parentManga?.title?["en"] ?? "")
//                    .lineLimit(1)
//                    .padding(.top)
//                    .padding(.horizontal)
//                    .font(.title3)
//                
//                Rectangle()
//                    .frame(height: 1)
//                    .padding(.top, 0)
//                    .foregroundStyle(.secondary)
//                
//                HStack {
//                    NavigationLink {
//                        DeferView {
//                            MangaView(cover: update.cover, id: update.chapters.first!.parentManga!.id)
//                        }
//                    } label : {
//                        CachedAsyncImage(url: URL(string: "https://uploads.mangadex.org/covers/\(update.chapters.first!.parentManga!.id.uuidString.lowercased())/\(update.cover.fileName).512.jpg")) { image in
//                            image
//                                .resizable()
//                                .scaledToFit()
//                        } placeholder: {
//                            ProgressView()
//                        }
//                        .clipShape(RoundedRectangle(cornerRadius: 9))
//                        .frame(width: 125 , alignment: .center)
//                    }
//                    
//                    ChapterListView(chapters: update.chapters)
//            }
//        }
//        .frame(height: 250)
//        .padding(.horizontal, 5)
//        .cardStyle()
//        
//    }
//}
//
//struct UpdatesView: View {
//    @State private var mangaUpdatesLogger: MangaUpdatesLogger = MangaUpdatesLogger(updates: [Update](), limit: 25, offset: 0, total: 0, latestUpdate: Date.now)
//    @State private var isLoading: Bool = false
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                LazyVStack {
//                    ForEach(mangaUpdatesLogger.updates) { update in
//                        MangaUpdateView(update: update)
//                            .padding(.horizontal)
//                    }
//                    .overlay(
//                        Group {
//                            if isLoading {
//                                ProgressView()
//                            }
//                        }
//                    )
//                    
//                    Color.clear
//                        .frame(height: 1)
//                        .onAppear {
//                            if !isLoading {
//                                Task {
//                                    isLoading = true
//                                    do {
//                                        let (updates, offset) = try await getUserFollowedFeed(limit: mangaUpdatesLogger.limit, offset: mangaUpdatesLogger.offset)
//                                        mangaUpdatesLogger.updates.append(contentsOf: updates)
//                                        mangaUpdatesLogger.offset = mangaUpdatesLogger.limit + offset
//                                    } catch let error as DecodingError {
//                                        handleDecodingError(error)
//                                    } catch {
//                                        print("Error: ", error.localizedDescription)
//                                    }
//                                    isLoading = false
//                                }
//                            }
//                        }
//                }
//            }
//            .background(Color(UIColor.systemGroupedBackground))
//            .navigationTitle("Updates")
//            .scrollIndicators(.never)
//        }
//    }
//}
//
//func getUserFollowedFeed(limit: Int, offset: Int) async throws -> (updates: [Update], offset: Int) {
//    var components = URLComponents()
//    components.scheme = "https"
//    components.host = "api.mangadex.org"
//    components.path = "/user/follows/manga/feed"
//    
//    let order: String = "desc" // TODO: change to load from userDefaults
//    
//    components.queryItems = [
//        URLQueryItem(name: "limit", value: "\(limit)"),
//        URLQueryItem(name: "offset", value: "\(offset)"),
//        URLQueryItem(name: "translatedLanguage[]", value: "en"), // TODO: change to load from userDefaults
//        URLQueryItem(name: "contentRating[]", value: "safe"),
//        URLQueryItem(name: "contentRating[]", value: "suggestive"),
//        URLQueryItem(name: "contentRating[]", value: "erotica"),
//        URLQueryItem(name: "contentRating[]", value: "pornographic"),
//        URLQueryItem(name: "order[createdAt]", value: order),
//        URLQueryItem(name: "order[updatedAt]", value: order),
//        URLQueryItem(name: "order[publishAt]", value: order),
//        URLQueryItem(name: "order[readableAt]", value: order),
//        URLQueryItem(name: "order[volume]", value: order),
//        URLQueryItem(name: "order[chapter]", value: order),
//        URLQueryItem(name: "includes[]", value: "manga"),
//        URLQueryItem(name: "includes[]", value: "user"),
//        URLQueryItem(name: "includes[]", value: "scanlation_group")
//    ]
//    
//    guard let url = components.url else {
//        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
//    }
//    
//    struct Root: Decodable {
//        let data: [Chapter]
//        let limit: Int
//        let offset: Int
//        let total: Int
//    }
//    
//    let data = try await authGet(from: url)
//    let chapters = try JSONDecoder().decode(Root.self, from: data)
//    
//    var updates = [Update]()
//    var filtered = [[Chapter]]()
//    var ids = [UUID]()
//    
//    for chapter in chapters.data {
//        let id = chapter.parentManga!.id
//        if (!ids.contains(id)) {
//            filtered.append(chapters.data.filter{ id == $0.parentManga!.id} )
//            ids.append(id)
//        }
//    }
//    
//    ids = filtered.map { $0.first!.parentManga!.id }
//    
//    let covers = try await getCovers(for: ids)
//    let markers = try await getReadMarkers(for: ids)
//    
//    for chapters in filtered {
//        if let readChapters = markers[chapters.first!.parentManga!.id.uuidString.lowercased()] {
//            for var chapter in chapters {
//                chapter.updateReadMarker(to: readChapters.contains(chapter.id.uuidString.lowercased()))
//            }
//        }
//    }
//    
//    for i in 0..<filtered.count {
//        updates.append(Update(id: i + offset, chapters: filtered[i], cover: covers[i]))
//    }
//    
//    return (updates: updates , offset: chapters.offset)
//}
//
//func getCovers(for chapters: [UUID]) async throws -> [Cover] {
//    let data = try await getCoversFor(ids: chapters).covers
//    var covers = [Cover]()
//    
//    for id in chapters {
//        if let cover = data.first(where: { $0.relationships!.first!.id == id }) {
//            covers.append(cover)
//        } else {
//            try await covers.append(contentsOf: getCovers(for: [id]))
//        }
//    }
//    
//    return covers
//}
//
//func getReadMarkers(for mangaIds: [UUID]) async throws -> [String: [String]] {
//    var components = URLComponents()
//    components.scheme = "https"
//    components.host = "api.mangadex.org"
//    components.path = "/manga/read"
//    components.queryItems = []
//    
//    for id in mangaIds {
//        components.queryItems?.append(URLQueryItem(name: "ids[]", value: id.uuidString.lowercased()))
//    }
//    
//    components.queryItems?.append(URLQueryItem(name: "grouped", value: "true"))
//    
//    guard let url = components.url else {
//        throw MDApiError.invalidURL(context: "URL could not be constructed from components: \(components.string ?? "no components").")
//    }
//    
//    struct Root: Decodable { let data: [String: [String]] }
//    
//    let data = try await authGet(from: url)
//    let markers = try JSONDecoder().decode(Root.self, from: data)
//    return markers.data
//}

struct UpdatesView: View {
    var body: some View {
        Text("Hello World!")
    }
}

extension UpdatesView {
    struct Update {
        var chapters: [Chapter]
        var cover: Cover
    }
    
    
    
    @Observable
    class Model {
        private(set) var updates: [Update] = []
        private(set) var readMarkers: [String] = []
        private(set) var isLoading: Bool = false
        private var offset = 0
        
        private func fetchChapters(for ids: [UUID]) async throws -> [Cover] {
            let entity = CoverFromMangaListEntity(ids: ids, limit: 100)
            let request = CoverListFromMangaRequest(entity)
            return try await request.execute()
        }
        
        private func fetchReadMarkers() async throws {
            
        }
        
        func fetchUpdates() async throws {
            guard !self.isLoading else { return }
            defer { self.isLoading = false }
            isLoading = true
            let entity = FollowedFeedEntity(limit: self.offset == 0 ? 25 : 100, offset: self.offset)
            let request = ListRequest<FollowedFeedEntity>(entity)
            async let (chapters, offset, total) = request.execute()
            let parentManga = try await chapters.map { $0.parentManga!.id }.removingDuplicates()
        }
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDictionary = [Element: Bool]()
        return filter { addedDictionary.updateValue(true, forKey: $0) == nil }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

#Preview {
    UpdatesView()
}
