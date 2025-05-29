//
//  UpdatesView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//
import SwiftData
import SwiftUI

/// A wrapper struct around the elements required to make a update item.
struct Update {
    /// The chapters returned by the /follows/feed endpoint.
    var chapters: [Chapter]
    
    /// The cover of the manga this update's chpaters belong to.
    var cover: Cover
    
    /// The manga this update's chapters belong to.
    var manga: Manga
}

extension Update {
    /// Returns the URL this updata's cover is found at.
    ///
    /// The URL for a lower quality cover image will be returned if data saver mode is enabled.
    var coverURL: URL {
        var compontents = URLComponents()
        compontents.scheme = "https"
        compontents.host = "uploads.mangadex.org"
        compontents.path = "/covers/\(manga.id.uuidString.lowercased())/\(cover.fileName).\(UserDefaults.standard.bool(forKey: "dataSaver") ? "256" : "512").jpg"
        return compontents.url!
    }
}

/// Used to sort updates so the newest is presented frist.
extension Update: Comparable {
    /// Indicateds which update was more recently readable.
    ///
    /// - Parameters:
    ///     - lhs: an update to be compared.
    ///     - rhs: another update to be compared.
    ///
    /// - Returns: True if the rhs was available to read more recently than the lhs.
    static func < (lhs: Update, rhs: Update) -> Bool {
        return lhs.chapters.first!.readableAt < rhs.chapters.first!.readableAt
    }
    
    /// Indicated is if two updates were readable at the same time.
    ///
    /// - Note: It is highly unlikely for two updates to have chaters with the same readableAt value,
    ///         but the implementation of this function is included if such a case occurs.
    ///
    /// - Parameters:
    ///     - lhs: an update to be compared.
    ///     - rhs: another update to be compared.
    /// - Returns: True if both the lhs and rhs were readable at the same time.
    static func == (lhs: Update, rhs: Update) -> Bool {
        return lhs.chapters.first!.readableAt == rhs.chapters.first!.readableAt
    }
}

extension Chapter {
    /// Constructs a complete title for a chapter of a specfic manga.
    ///
    /// For example the formated full title for chapter one of Tokyo Ghoul would be`Vol. 1 Ch. 5 - Coffee`.
    var fullTitle: String {
        if let volume = self.volume {
            return "Vol. \(volume) Ch. \(self.chapter ?? "0") \(self.title != nil && self.title != "" ? "- \(self.title!)" : "")"
        } else { return "Ch. \(self.chapter ?? "0") \(self.title != nil ? "- \(self.title!)" : "")" }
    }
}

/// An extension for removing duplicates from any array containing hashable elements.
///
/// [Source](https://www.hackingwithswift.com/example-code/language/how-to-remove-duplicate-items-from-an-array)
extension Array where Element: Hashable {
    /// Returns a copy of self with all duplicate elements removed.
    ///
    /// - Returns: an array of hashable elements with no duplicate items.
    func removingDuplicates() -> [Element] {
        var addedDictionary = [Element: Bool]()
        return filter { addedDictionary.updateValue(true, forKey: $0) == nil }
    }
    
    /// Sets self to an array with duplicates removed.
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

/// Each row of an update's chapter list diplays the chapter's title, upload data, the scanlation group and
/// user who uploaded it, and whether or not its has been read.
struct ChapterListRow: View {
    /// The chapter displayed in this row.
    @Binding var chapter: Chapter
    
    /// A single row displaying a a chapter's title, and its related information.
    var body: some View {
        NavigationLink {
            // TODO: link to external website if chapter has externalLink
            ReaderView(chapter: chapter, title: "Ch. \(chapter.chapter ?? "0") \(chapter.title ?? "")")
            /// Fixes a weird animation bug that occurs when new views that cover the tab bar are pushed onto the nagivation stack.
                .navigationBarBackButtonHidden(true)
        } label: {
            // TODO: change to light font size?
            HStack {
                VStack(alignment: .leading) {
                    /// TODO: add readmarkers
                    Image(systemName: "eye")
                    Image(systemName: "person.2")
                }
                
                VStack(alignment: .leading) {
                    Text(chapter.fullTitle)
                        .lineLimit(1)
                    Text(chapter.scanlationGroup?.name ?? "No group")
                        .lineLimit(1)
                }
            }
        }
    }
}

/// A list of all chapters in a specific update.
struct ChapterList: View {
    /// The chapters displayed in this list.
    @Binding var chapters: [Chapter]
    
    /// A list of chapters sorted descending order of chapter number, or upload date if the chapter does not have a number.
    var body: some View {
        //        List {
        ForEach($chapters) { chapter in
            ChapterListRow(chapter: chapter)
            //                    .listRowBackground(Color.clear)
                .foregroundStyle(.primary)
            //            }
        }
        .listRowInsets(.none)
        .scrollIndicators(.never)
        .listStyle(.plain)
    }
}

/// A single row of the updates list. Each item is presented in a "card" style.
struct UpdateListRow: View {
    /// The update displayed in this row.
    @State var update: Update
    
    /// Displays a single update containing the cover of the update's manga, and its chapters.
    var body: some View {
        HStack(alignment: .top) {
            NavigationLink {
                MangaView(manga: update.manga)
            } label: {
                CachedAsyncImage(url: update.coverURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 115, height: 169)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading) {
                Text(update.manga.localizedTitle)
                    .lineLimit(1)
                    .font(.title3)
                //                    .padding(.top, 7)
                
                Rectangle().frame(height: 1).backgroundStyle(.white)
                
                ChapterList(chapters: $update.chapters)
                    .ignoresSafeArea()
            }
        }
        .frame(minHeight: 180, alignment: .top)
    }
}

/// A list of all chapters in a user's followed manga feed.
struct UpdatesView: View {
    /// A model encapsulating all data used by this view.
    @State private var model = Model()
    
    /// Displays the most recently uploaded chapters from a user's followed manga feed.
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    /// Display all user updates in a scrollable list.
                    ForEach(model.updates, id: \.self.chapters.first!.id) { update in
                        UpdateListRow(update: update)
                            .padding(.bottom, 3)
                    }
                    
                    Color.clear
                        .frame(height: 1)
                        .onAppear { Task { try? await model.fetchUpdates() } }
                }
            }
            .overlay(Group { if model.isLoading { ProgressView() } })
            .scrollIndicators(.never)
            .refreshable { try? await model.refreshUpdates() }
            .navigationTitle("Updates")
        }
    }
}

extension UpdatesView {
    /// A class used to encapsulate the data returned when fetching a users followed manga feed.
    @Observable
    class Model {
        /// All new "updates" for a users followed manga.
        ///
        /// Fetched updates are only a colleciton of chapters, but other data has been added to improve the interface and navigation experience.
        private(set) var updates: [Update] = []
        
        /// A dictionary where the key is a manga's UUID, and the value is the UUIDs of all chapters that have been
        /// marked read.
        private(set) var readMarkers: [String: [String]] = [:]
        
        /// Indicates if this model is currently fetching data from the MangaDexAPI.
        private(set) var isLoading: Bool = false
        
        /// The starting index of the collection to be fetched.
        ///
        /// ### See Also
        /// [Pagnation](https://api.mangadex.org/docs/01-concepts/pagination/)
        private var offset = 0
        
        /// Replaces the current updates with most recently available ones.
        @MainActor
        func refreshUpdates() async throws {
            self.updates = []
            self.readMarkers = [:]
            self.offset = 0
            try await fetchUpdates()
        }
        
        /// Fetches the necesary data to display a list of a users updates.
        ///
        /// This function will fetch the first 25, then fetch 100 for all consecutive calls after that.
        ///
        /// - Note: All requests are encapsulated in this function to avoid data races.
        @MainActor
        func fetchUpdates() async throws {
            guard !self.isLoading else { return }
            defer { self.isLoading = false }
            self.isLoading = true
            
            let (chapters, _, _) = try await ListRequest<FollowedFeedEntity>(.init(limit: self.offset == 0 ? 25 : 100, offset: self.offset)).execute()
            let parentManga = chapters.map { $0.parentManga!.id }.removingDuplicates()
            
            async let covers = CoverListFromMangaRequest(.init(ids: parentManga, limit: parentManga.count)).execute()
            async let readMarkers = Request<ReadMarkerGroupEntity>(.init(ids: parentManga)).execute()
            async let (manga, _, _) = ListRequest<MangaListEntity>(.init(ids: parentManga, limit: parentManga.count)).execute()
            
            let groupedChapters = Dictionary(grouping: chapters, by: { $0.parentManga!.id })
            
            for (key, value) in groupedChapters {
                self.updates.append(Update(chapters: value, cover: try await covers.first(where: { $0.1 == key })!.0, manga: try await manga.first(where: { $0.id == key })!))
            }
            
            self.offset += 100
            self.updates.sort(by: >)
            self.readMarkers = try await readMarkers
        }
    }
}

#Preview {
    UpdatesView()
}
