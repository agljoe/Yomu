//
//  UpdatesView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import Foundation
import SwiftUI

struct Update: Identifiable {
    var id: Int
    var chapters: [Chapter]
    var cover: Cover
}

struct MangaUpdatesLogger {
    var updates: [Update]
    var limit: Int
    var offset: Int
    var total: Int
    var latestUpdate: Date
    
    init(updates: [Update], limit: Int, offset: Int, total: Int, latestUpdate: Date) {
        self.updates = updates
        self.limit = limit
        self.offset = offset
        self.total = total
        self.latestUpdate = latestUpdate
    }
}

struct ChapterListView: View {
    let chapters: [Chapter]
    
    var body: some View {
        List(chapters) { chapter in
            Section {
                NavigationLink {
                    // TODO: link to external website if chapter has externalLink
                    ReaderView(chapterId: chapter.id, title: "Ch. \(chapter.chapter ?? "0") \(chapter.title ?? "")")
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack {
                        VStack(alignment: .center) {
                            Button {
                                // TODO
                            } label : {
                                Image(systemName: "eye")
                            }
                            
                            Image(systemName: "person.3")
                        }
                        
                        VStack(alignment: .leading) {
                            Text("\(chapter.volume != nil ? "Vol. \(chapter.volume ?? "0")" : "") Ch. \(chapter.chapter ?? "0") \(chapter.title ?? "")")
                                .lineLimit(1)
                            Text(chapter.scanlationGroup?.name ?? "No group")
                                .lineLimit(1)
                        }
                    }
                }
            }
            .listRowBackground(Color.clear)
        }
        .scrollIndicators(.never)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

struct MangaUpdateView: View {
    let update: Update
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "https://uploads.mangadex.org/covers/\(update.chapters.first!.parentManga!.id.uuidString.lowercased())/\(update.cover.fileName)")) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: 100 , alignment: .top)
            .padding(.leading, 10)
            .padding(.top, 0)
            .padding(.bottom, 30)

            VStack {
                Text(update.chapters.first!.parentManga?.title["en"] ?? "")
                    .lineLimit(1)
                    .padding(.top, 10)
                    .font(.title3)
                
                Rectangle()
                    .frame(height: 1)
                    .padding(.top, 0)
                    .foregroundStyle(.secondary)
                
                ChapterListView(chapters: update.chapters)
            }
            .frame(alignment: .leading)
        }
        .frame(height: 200)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct UpdatesView: View {
    @State private var mangaUpdatesLogger: MangaUpdatesLogger = MangaUpdatesLogger(updates: [Update](), limit: 25, offset: 0, total: 0, latestUpdate: Date.now)
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(mangaUpdatesLogger.updates) { update in
                        MangaUpdateView(update: update)
                    }
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            if !isLoading {
                                Task {
                                    isLoading = true
                                    do {
                                        let (updates, offset) = try await getUserFollowedFeed(limit: mangaUpdatesLogger.limit, offset: mangaUpdatesLogger.offset)
                                        mangaUpdatesLogger.updates.append(contentsOf: updates)
                                        mangaUpdatesLogger.offset = mangaUpdatesLogger.limit + offset
                                    } catch let error as DecodingError {
                                        handleDecodingError(error)
                                    } catch {
                                        print("error: ", error.localizedDescription)
                                    }
                                    isLoading = false
                                }
                            }
                        }
                }
            }
            .navigationTitle("Updates")
            .scrollIndicators(.never)
        }
    }
}

func getUserFollowedFeed(limit: Int, offset: Int) async throws -> (updates: [Update], offset: Int) {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/user/follows/manga/feed"
    
    let order: String = "desc" // TODO: change to load from userDefaults
    
    components.queryItems = [
        URLQueryItem(name: "limit", value: "\(limit)"),
        URLQueryItem(name: "offset", value: "\(offset)"),
        URLQueryItem(name: "translatedLanguage[]", value: "en"), // TODO: change to load from userDefaults
        URLQueryItem(name: "contentRating[]", value: "safe"),
        URLQueryItem(name: "contentRating[]", value: "suggestive"),
        URLQueryItem(name: "contentRating[]", value: "erotica"),
        URLQueryItem(name: "contentRating[]", value: "pornographic"),
        URLQueryItem(name: "order[createdAt]", value: order),
        URLQueryItem(name: "order[updatedAt]", value: order),
        URLQueryItem(name: "order[publishAt]", value: order),
        URLQueryItem(name: "order[readableAt]", value: order),
        URLQueryItem(name: "order[volume]", value: order),
        URLQueryItem(name: "order[chapter]", value: order),
        URLQueryItem(name: "includes[]", value: "manga"),
        URLQueryItem(name: "includes[]", value: "user"),
        URLQueryItem(name: "includes[]", value: "scanlation_group")
    ]
    
    guard let url = components.url else { throw MDApiError.invalidURL(context: "Url could not be constructed from components: \(components.string ?? "Unknown")") }
    
    struct Root: Decodable {
        let data: [Chapter]
        let limit: Int
        let offset: Int
        let total: Int
    }
    
    let data = try await authGet(from: url)
    let chapters = try JSONDecoder().decode(Root.self, from: data)
    
    var updates = [Update]()
    var filtered = [[Chapter]]()
    var ids = [UUID]()
    
    for chapter in chapters.data {
        let id = chapter.parentManga!.id
        if (!ids.contains(id)) {
            filtered.append(chapters.data.filter{ id == $0.parentManga!.id} )
            ids.append(id)
        }
    }
    
    let covers = try await getCovers(for: filtered.map { $0.first!.parentManga!.id })
    
    for i in 0..<filtered.count {
        updates.append(Update(id: i + offset, chapters: filtered[i], cover: covers[i]))
    }
    
    return (updates: updates , offset: chapters.offset)
}

func getCovers(for chapters: [UUID]) async throws -> [Cover] {
    let data = try await getCoversFor(ids: chapters)?.covers ?? []
    
    var covers = [Cover]()
    
    for id in chapters {
        if let cover = data.first(where: { $0.relationships.first!.id == id }) {
            covers.append(cover)
        } else {
            do {
                let cover = try await getCoversFor(ids: [id])
                covers.append(cover!.covers.first!)
            } catch let error as DecodingError {
                print(handleDecodingError(error))
            } catch { print(error.localizedDescription) }
        }
    }
    
    return covers
}

#Preview {
    UpdatesView()
}
