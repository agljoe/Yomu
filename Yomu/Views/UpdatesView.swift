//
//  UpdatesView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

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
                    ReaderView(chapterId: chapter.id, title: "Ch. " + chapter.chapter  + " " + (chapter.title ?? ""))
                        .lineLimit(1)
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
                            Text("Ch. " + chapter.chapter  + " " + (chapter.title ?? ""))
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
            .frame(height: 150 , alignment: .top)
            .padding(.leading, 8)
            .padding(.top, 10)
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
        NavigationStack {
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
                                    do {
                                        isLoading = true
                                        let (updates, offset) = try await getUserFollowedFeed(limit: mangaUpdatesLogger.limit, offset: mangaUpdatesLogger.offset)
                                        mangaUpdatesLogger.updates.append(contentsOf: updates)
                                        mangaUpdatesLogger.offset = mangaUpdatesLogger.limit + offset
                                    } catch let DecodingError.dataCorrupted(context) {
                                        print(context)
                                    } catch let DecodingError.keyNotFound(key, context) {
                                        print("Key '\(key)' not found:", context.debugDescription)
                                        print("codingPath:", context.codingPath)
                                    } catch let DecodingError.valueNotFound(value, context) {
                                        print("Value '\(value)' not found:", context.debugDescription)
                                        print("codingPath:", context.codingPath)
                                    } catch let DecodingError.typeMismatch(type, context)  {
                                        print("Type '\(type)' mismatch:", context.debugDescription)
                                        print("codingPath:", context.codingPath)
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
    
    guard let url = components.url else { throw MDApiError.invalidURL }
    
    struct Root: Decodable {
        let data: [Chapter]
        let limit: Int
        let offset: Int
        let total: Int
    }
    
    let data = try await authGet(for: url)
    let chapters = try JSONDecoder().decode(Root.self, from: data)
    
    var updates = [Update]()
    var filtered = [[Chapter]]()
    
    var index = 0
    var cursor = 0
    
    while(index < chapters.data.count) {
        filtered.append(chapters.data.filter{ chapters.data[index].parentManga!.id == $0.parentManga!.id })
        index += filtered[cursor].count
        
        if filtered[cursor].count + index >= chapters.data.count { break }
        
        cursor += 1
    }
    
    let covers = try await getCovers(for: filtered.map { $0.first!.parentManga!.id }, total: filtered.map { Int($0.first!.volume ?? "1") ?? 0}.reduce(0, +))
    
    for i in 0..<filtered.count {
        updates.append(Update(id: i + offset, chapters: filtered[i], cover: covers[i]))
    }
    
    return (updates: updates , offset: chapters.offset)
}

func getCovers(for chapters: [UUID], total: Int) async throws -> [Cover] {
    let limit = total > 100 ? 100 : total
    
    let data = try await getCoversFor(ids: chapters, limit: limit)
    
    var covers = [Cover]()
    
    for id in chapters {
        if let cover = data.first(where: { $0.relationships.first!.id == id }) {
            covers.append(cover)
        } else {
            do {
                let cover = try await getCoversFor(ids: [id], limit: 1)
                covers.append(cover.first!)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    return covers
}

func updateFeed(for logger: inout MangaUpdatesLogger) async {
    do {
        let (updates, offset) = try await getUserFollowedFeed(limit: logger.limit, offset: logger.offset)
        logger.updates.append(contentsOf: updates)
        logger.offset = logger.limit + offset
    } catch let DecodingError.dataCorrupted(context) {
        print(context)
    } catch let DecodingError.keyNotFound(key, context) {
        print("Key '\(key)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)
    } catch let DecodingError.valueNotFound(value, context) {
        print("Value '\(value)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)
    } catch let DecodingError.typeMismatch(type, context)  {
        print("Type '\(type)' mismatch:", context.debugDescription)
        print("codingPath:", context.codingPath)
    } catch {
        print("error: ", error.localizedDescription)
    }
}


#Preview {
    UpdatesView()
}
