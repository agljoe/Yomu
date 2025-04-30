//
//  MangaView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-13.
//

import Foundation
import SwiftUI

extension Manga {
    /// Returns the URL this updata's cover is found at.
    ///
    /// The URL for a lower quality cover image will be returned if data saver mode is enabled.
    var coverURL: URL {
        var compontents = URLComponents()
        compontents.scheme = "https"
        compontents.host = "uploads.mangadex.org"
        compontents.path = "/covers/\(self.id.uuidString.lowercased())/\(self.cover.fileName).\(UserDefaults.standard.bool(forKey: "dataSaver") ? "256" : "512").jpg"
        return compontents.url!
    }
    
    /// Returns the appropriate title of a manga based on a users language preferneces.
    ///
    /// This variable can return and empty string, but there should be no cases in which this occurs.
    var localizedTitle: String {
        // TODO: get title in users prefered language if available and is wanted
        if let title = self.title[self.title.keys.first ?? "en"] { return title }
        if let alternateEnglishTitle = self.altTitles.first(where: { $0.keys.contains("en") })?.values.first { return alternateEnglishTitle }
        if let romanizedTitle = self.altTitles.first(where: { $0.keys.contains("\(self.originalLanguage)-ro") })?.values.first { return romanizedTitle }
        return ""
    }
    
    /// Returns either the first alternate English title, or original language title of a manga if they exist.
    var alternateTitle: String {
        if let alternateEnglishTitle = self.altTitles.first(where: { $0.keys.contains("en") })?.values.first { return alternateEnglishTitle }
        if let originalTitle = self.altTitles.first(where: { $0.keys.contains(self.originalLanguage) })?.values.first { return originalTitle }
        return ""
    }
}

extension Chapter {
    /// The title of this chapter formated for presentation when grouped by its volume.
    ///
    /// For example the formated title for chapter one of The Rising of the Sheild Hero would be `Ch.1 - A Royal Summons`.
    var volumeListTitle: String {
        "Ch. \(self.chapter ?? "0") \(self.title ?? "")"
    }
}

extension ChaptersByVolumeListView {
    /// The total number of chapters 
    var totalChapters: Int {
        chapters.reduce(0, { $0 + $1.value.count })
    }
    
    var totalVolumes: Int {
        chapters.keys.count
    }
}


/// A list of sections for each volume of a manga where each section contains the chapters of the respective volume.
struct ChaptersByVolumeListView: View {
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    var chapters: [String: [Chapter]]
    
    var body: some View {
        List(chapters.keys.sorted(using: String.Comparator(options: [.diacriticInsensitive, .caseInsensitive, .numeric], order: .reverse)), id: \.self) { volume in
            Section(header: Text(volume == "No Volume" ? volume : "Volume \(volume)")) {
                ForEach(chapters[volume]!) { chapter in
                    NavigationLink {
                        ReaderView(chapter: chapter, title: chapter.fullTitle)
                    } label: {
                        Text(chapter.volumeListTitle)
                            .lineLimit(1)
                    }
                }
            }
        }
        .scrollDisabled(true)
        .listStyle(.plain)
        .scrollIndicators(.never)
        .frame(height: minRowHeight * CGFloat(totalChapters) + CGFloat(totalVolumes * 55) + CGFloat(totalChapters < 4 ? 200 : 0), alignment: .top)
    }
}

struct MangaTitleView: View {
    var title: String
    var altTitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .backgroundStyle(.white)
                .lineLimit(2)
            
            Text(altTitle)
                .font(.title3)
                .backgroundStyle(.white)
        }
    }
}

struct AuthorScrollView: View {
    let authors: [Author]
    
    var body: some View {
        ScrollView(.horizontal) {
            List(authors) {
                Text($0.name)
                    .cardStyle()
            }
            .listStyle(.plain)
            .listRowBackground(Color.clear)
        }
        .scrollIndicators(.never)
        .scrollContentBackground(.hidden)
    }
}

struct MangaView: View {
    @State var model: Model
    
    init(manga: Manga) {
        self.model = Model(manga: manga)
        self._model = .init(initialValue: model)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    HStack {
                        CachedAsyncImage(url: model.manga.coverURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack {
                            MangaTitleView(title: model.manga.localizedTitle, altTitle: model.manga.alternateTitle)
                            
                            HStack {
                                AuthorScrollView(authors: model.manga.author)
                                AuthorScrollView(authors: model.manga.artist)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(try! AttributedString(markdown: model.manga.description["en"] ?? ""))
                    }
                    
                    ChaptersByVolumeListView(chapters: model.chapters)
                }
            }
            .scrollIndicators(.never)
        }
        .overlay(Group { if model.isLoading { ProgressView() } })
        .task { try? await model.fetchManga() }
        .refreshable { try? await model.fetchManga() }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension MangaView {
    
    @Observable
    class Model {
        private(set) var manga: Manga
        private(set) var chapters: [String: [Chapter]] = [:]
        private(set) var readMarkers: [String] = []
        private(set) var isLoading: Bool = false
        
        init(manga: Manga) {
            self.manga = manga
        }
        
        @MainActor
        func fetchManga() async throws {
            guard !isLoading else { return }
            defer { isLoading = false }
            isLoading = true
            
            var lastTotal: Int = 0
            var totalChapters: [Chapter] = []
            /// Use a copy of self.id to avoid data races.
            let id = self.manga.id
            async let (chapters, _, total) = ListRequest<MangaFeedEntity>(MangaFeedEntity(id: id, limit: 500)).execute()
            async let readMarkers = Request<ReadMarkerEntity>(ReadMarkerEntity(id: id)).execute()
            
            lastTotal = try await total
    
            totalChapters = try await chapters
            
            while lastTotal >= 500 {
                async let (chapters, _, total) = ListRequest<MangaFeedEntity>(MangaFeedEntity(id: id, limit: 500, offset: 500)).execute()
                totalChapters.append(contentsOf: try await chapters)
                lastTotal = try await total
            }
            
            self.chapters = Dictionary(grouping: totalChapters, by: { $0.volume ?? "No Volume" })
            self.readMarkers = try await readMarkers
        }
    }
}

#if DEBUG
extension Bundle {
    func decode(from file: String) -> Manga {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()

        do {
            return try decoder.decode(Wrapper<Manga>.self, from: data).data
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
#endif

#Preview {
    MangaView(manga: Bundle.main.decode(from: "I Can't Say No to the Lonely Girl.json"))
}


