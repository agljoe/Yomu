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
    
    /// The URL for this manga at mangadex.org
    var openUrl: URL {
        URL(string: "https://mangadex.org/title/\(id.uuidString.lowercased())")!
    }
}

extension Chapter {
    /// The title of this chapter formated for presentation when grouped by its volume.
    ///
    /// For example the formated title for chapter one of The Rising of the Sheild Hero would be `Ch.1 - A Royal Summons`.
    var volumeListTitle: String {
        "Ch. \(self.chapter ?? "0") \(self.title != nil && self.title != "" ? "- \(self.title!)" : "")"
    }
}

extension ReadingStatus: Identifiable {
    /// Conformance to allow instances of ReadingStatus to be used in a ForEach.
    ///
    /// - Important: This does not garuntee that every ReadingStatus variable is unique.
    public var id: Self { self }
}

extension ReadingStatus {
    /// Returns a formatted string for each ReadinStatus case.
    var displayTitle: String {
        switch self {
        case .none:
            "None"
        case .reading:
            "Reading"
        case .on_hold:
            "On Hold"
        case .dropped:
            "Dropped"
        case .plan_to_read:
            "Plan to Read"
        case .completed:
            "Completed"
        case .re_reading:
            "Re-Reading"
        }
    }
    
    /// Returns the SFSymbol icon name associated with each ReadingStatus case.
    var systemImageName: String {
        switch self {
        case .none:
            "bookmark.slash.fill"
        case .reading:
            "book.fill"
        case .on_hold:
            "bookmark.fill"
        case .dropped:
            "archivebox.fill"
        case .plan_to_read:
            "books.vertical.fill"
        case .completed:
            "book.closed.fill"
        case .re_reading:
            "arrow.trianglehead.clockwise"
        }
    }
    
    /// Returns the color associated with each ReadingStatus case.
    var color: Color {
        switch self {
        case .none:
                .gray
        case .reading:
                .green
        case .on_hold:
                .orange
        case .dropped:
                .red
        case .plan_to_read:
                .purple
        case .completed:
                .cyan
        case .re_reading:
                .mint
        }
    }
}

/// Applies the style of a small icon.
struct MangaToolBarItem: ViewModifier {
    /// The size length of the content being styled.
    ///
    /// The returned content will have a square frame.
    let size: CGFloat
    
    /// The color of this item.
    let background: Color
    
    /// Creates a square with rounded corners around the given content.
    ///
    /// - Parameter content: the view to be modified.
    ///
    /// - Returns: the modified content.
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    /// Applys the MangaToolBarItem ViewModifier to the selected view.
    func mangaToolBarItem(size: CGFloat, background: Color = Color(UIColor.systemBackground)) -> some View {
        modifier(MangaToolBarItem(size: size, background: background))
    }
}

extension ChaptersByVolumeListView {
    /// Returns the total number of chapters, may include chapters with duplicate numbers.
    ///
    /// Duplicate chatpers do not have the same UUID.
    var totalChapters: Int {
        chapters.reduce(0, { $0 + $1.value.count })
    }
    
    /// Returns the total number of volumes, any group of chapters with no volume
    /// is also considered a volume.
    var totalVolumes: Int {
        chapters.keys.count
    }
}

/// A list of sections for each volume of a manga where each section contains the chapters of the respective volume.
struct ChaptersByVolumeListView: View {
    /// The minimum height needed for a row in the list of chapters.
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    /// A dictionary where the key is a volume number, and the value is the array
    /// of chapters that volume.
    var chapters: [String: [Chapter]]
    
    /// Displays the chapters of each volume as a distinct section of a list.
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
        /// Calulates the minimum frame size needed so the this list can be displayed in a scrollview.
        .frame(height: minRowHeight * CGFloat(totalChapters) + CGFloat(totalVolumes * 55) + CGFloat(totalChapters < 4 ? 200 : 0), alignment: .top)
    }
}

/// Displays the cover of a manga found at a specific URL.
///
/// This view attempts to get an image from the URL cache before loading it from the web.
struct CoverView: View {
    /// The URL the diplayed cover is found at.
    let url: URL
    
    /// Presents a manga's cover image with rounded corners.
    ///
    /// If the cover image cannot be dislpayed a ProgressView is presented in its place.
    var body: some View {
        CachedAsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 150, height: 221)
    }
}

/// Displays the title and one alternative tilte of a manga.
struct MangaTitleView: View {
    /// The title of a manga, this value can be localized.
    var title: String
    
    /// One of the alternative titles of a manga, usually in English.
    var altTitle: String
    
    /// DIsplays the title of a manga in bold text, and an alternate title
    /// as a subtitle.
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .backgroundStyle(.white)
            
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
            ForEach(authors) {
                Text($0.name)
                    .foregroundStyle(.secondary)
            }
            .listStyle(.plain)
            .listRowBackground(Color.clear)
        }
        .scrollIndicators(.never)
        .scrollContentBackground(.hidden)
    }
}

/// A group of buttons for interacting with a manga.
///
/// Manga tool bar buttons can be used to update the reading status, followed status,
/// or to open a manga in safari.
struct MangaToolBar: View {
    /// The user's reading status for this manga.
    @Binding var readingStatus: ReadingStatus
    
    /// Indicates if this manga's chapters appear in the user's followed feed.
    @Binding var isFollowed: Bool
    
    /// Indicates whether or not to display the SafariView for this manga.
    @Binding var isPresented: Bool
    
    /// The side length of buttons on this tool bar.
    private let toolBarItemSize: CGFloat = 30
    
    var body: some View {
        HStack {
            Menu {
                ForEach(ReadingStatus.allCases) { status in
                    Button {
                        readingStatus = status
                        //TODO: update reading status
                    } label: {
                        Text(status.displayTitle)
                    }
                }
            } label: {
                Image(systemName: readingStatus.systemImageName)
                    .mangaToolBarItem(size: toolBarItemSize, background: readingStatus.color)
            }
            
            Button {
                isFollowed.toggle()
                //TODO: update followed status
            } label: {
                Image(systemName: isFollowed ? "bell.fill" : "bell.slash.fill")
                    .mangaToolBarItem(size: toolBarItemSize, background: isFollowed ? .blue : .gray)
            }
            
            Button {
                self.isPresented = true
            } label: {
                Image(systemName: "safari")
                    .mangaToolBarItem(size: toolBarItemSize, background: .blue)
            }
        }
    }
}

struct MangaView: View {
    @State private var isPresented: Bool = false
    @State var model: Model
    
    init(manga: Manga) {
        self.model = Model(manga: manga)
        self._model = .init(initialValue: model)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    HStack(alignment: .top) {
                        CoverView(url: model.manga.coverURL)
                        
                        VStack(alignment: .leading) {
                            MangaTitleView(title: model.manga.localizedTitle, altTitle: model.manga.alternateTitle)
                            
                            HStack {
                                AuthorScrollView(authors: model.manga.author)
                                AuthorScrollView(authors: model.manga.artist)
                            }
                            
                            
                            MangaToolBar(readingStatus: $model.manga.readingStatus, isFollowed: $model.manga.isFollowed, isPresented: $isPresented)
                        }
                    }
                    .padding(.horizontal)
                    
                    Text(try! AttributedString(markdown: model.manga.description["en"] ?? ""))
                        .padding(.horizontal)
                    ChaptersByVolumeListView(chapters: model.chapters)
                }
            }
            .scrollIndicators(.never)
        }
        .safariView(isPresented: $isPresented) {
            SafariView(url: model.manga.openUrl, configuration:  .init(entersReaderIfAvailable: false, barCollapsingEnabled: true))
                .preferredBarAccentColor(.clear)
                .preferredControlAccentColor(.accentColor)
                .dismissButtonStyle(.done)
        }
        .overlay(Group { if model.isLoading { ProgressView() } })
        .task { try? await model.fetchManga() }
        .refreshable { try? await model.fetchManga() }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension MangaView {
    ///
    @Observable
    class Model {
        var manga: Manga
        private(set) var chapters: [String: [Chapter]] = [:]
        private(set) var readMarkers: [String] = []
        private(set) var isLoading: Bool = false
        // TODO: add statistics
        
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
            async let (chapters, _, total) = ListRequest<MangaFeedEntity>(.init(id: id, limit: 500)).execute()
            async let readMarkers = Request<ReadMarkerEntity>(.init(id: id)).execute()
            async let readingStatus = MangaReadingStatusRequest(for: id).execute()
            async let followed = CheckIfMangaIsFollowedRequest(id: id).execute()
            
            lastTotal = try await total
            totalChapters = try await chapters
            
            while lastTotal >= 500 {
                async let (chapters, _, total) = ListRequest<MangaFeedEntity>(.init(id: id, limit: 500, offset: 500)).execute()
                totalChapters.append(contentsOf: try await chapters)
                lastTotal = try await total
            }
            
            self.chapters = Dictionary(grouping: totalChapters, by: { $0.volume ?? "No Volume" })
            self.readMarkers = try await readMarkers
            self.manga.readingStatus = ReadingStatus(rawValue: try await readingStatus)!
            self.manga.isFollowed = try await followed
            
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

        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone.current
        
        decoder.dateDecodingStrategy = .formatted(RFC3339DateFormatter)

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

extension Manga {
    func updatingStatus() -> Manga {
        var temp = self
        temp.readingStatus = .completed
        temp.isFollowed = true
        return temp
    }
}
#endif

#Preview {
    MangaView(manga: Bundle.main.decode(from: "I Can't Say No to the Lonely Girl.json").updatingStatus())
}


