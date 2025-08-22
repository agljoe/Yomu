//
//  MangaView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-13.
//

import Foundation
import MangaDexData
import MangaDexAPIKit
import SwiftUI

/// All available sort orderings for chapters displayed in a `MangaView`.
private enum Sort: String, CaseIterable, Identifiable {
    /// Places the largest value first.
    ///
    /// Chapters will appear in order by chapter number 1, 2, ..., n - 1, n.
    case ascending = "Ascending"
    
    /// Places the smallest value first.
    ///
    /// Chapters will appear in order by chapter number n, n - 1, ..., 2, 1.
    case descending = "Descending"
    
    /// Places the most recently uploaded chapter first.
    ///
    /// - Note: Chapters may have a more recent `updatedAt` date, which is not considered for
    ///         this sorting option.
    case uploadAt = "Upload Date"
    
    /// Allows the cases of this enum to be used in a `ForEach`.
    var id: Self { self }
}

/// All available display filters for chapters displayed in a `MangaView`.
private enum DisplayMode: String, CaseIterable, Identifiable {
    /// All available chapters.
    case all = "All"
    
    /// All chapters that have been downloaded.
    case downloaded = "Downloaded"
    
    /// All chapters or volumes with available unread chapters.
    case unread = "Unread"
    
    /// Allows the cases of this enum to be used in a `ForEach`.
    var id: Self { self }
}

/// Displays the data associated with a manga, such as its chapters, covers, and authors.
struct MangaView: View {
    /// The device's current color scheme.
    @Environment(\.colorScheme) private var colorScheme
    
    /// The minimum row height need to display a single row in a `List`.
    @Environment(\.defaultMinListRowHeight) private var minRowHeight
    
    ///
    @Environment(\.dismiss) private var dismiss
    
    /// Indicates is the info sheet for this manga is being displayed.
    @State private var isShowingSheet: Bool = false
    
    /// Indicates if this manga is being displayed using in-app Safari.
    @State private var isPresented: Bool = false
    
    /// Indicates wether volumes or chapters are displayed.
    @State private var activeTab: TabModel = .volumes
    
    /// A view model that hadles the logic and networking requied to display a manga.
    @State private var model: MangaViewModel
    
    /// The order the displayed chapters are sorted by.
    @State private var sortBy: Sort = .descending
    
    /// The filter applied to the displayed chapters.
    @State private var displayMode: DisplayMode = .all
    
    /// Creates a `MangaViewModel` with the given manga that can be used to
    /// initialize this view.
    ///
    /// - Parameter manga: a `PersistentManga`.
    ///
    /// - Returns: a newly created `MangaView` initalized with a `MangaViewModel` for the specified `PersistentManga`.
    init(manga: PersistentManga) {
        self.model = MangaViewModel(manga: manga)
        self._model = .init(initialValue: model)
    }
    
    /// Displays a manga an its related information.
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 15) {
                    CoversAndTitleView()
                    
                    LazyVStack(alignment: .leading) {
                        CustomTabBar(activeTab: $activeTab)
                            .padding(.horizontal, 30)
                            .padding(.top)
                        
                        switch activeTab {
                        case .volumes:
                            VolumesList()
                                .padding(.top, -10)
                        case .chapters:
                            ChaptersList()
                                .padding(.top, -10)
                        }
                    }
                    .background {
                        Rectangle()
                            .fill(colorScheme == .dark ? .black : .white)
                            .ignoresSafeArea(.all)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            MangaInfoSheet()
        }
        .safariView(isPresented: $isPresented) {
            SafariView(
                url: model.manga.openUrl,
                configuration:  .init(
                    entersReaderIfAvailable: false,
                    barCollapsingEnabled: true
                )
            )
            .preferredBarAccentColor(.clear)
            .preferredControlAccentColor(.accentColor)
            .dismissButtonStyle(.done)
        }
        // TODO: add background or make extra loading view that can be shown
        .overlay(Group { if model.isLoading { ProgressView() } })
        .task {
            do {
                if (model.manga.chapters.isEmpty) {
                    try await model.updateManga()
                }
            } catch let error {
                print(error)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // TODO: support swipe to go back
    /// Creates the header buttons for view dismissal, and chapter display options.
    ///
    /// - Returns: An `HStack` with a back button, and a `Menu`.
    func FixedHeaderView() -> some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left.circle.fill")
            }
            .buttonStyle(.plain)
            .font(.title)
            .foregroundStyle(.white, .white.tertiary)
            
            Spacer()
            
            Menu {
                ShareLink(item: URL(string: "https://mangadex.org/title/\(model.manga.id.uuidString.lowercased())")!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                
                Picker(selection: $displayMode, label: Text("View")) {
                    ForEach(DisplayMode.allCases) { display in
                        Text(display.rawValue)
                    }
                }
                .labelsVisibility(.visible)
                
                
                Picker(selection: $sortBy, label: Text("Sort by")) {
                    ForEach(Sort.allCases) { order in
                        Text(order.rawValue)
                    }
                }
                .labelsVisibility(.visible)
                
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .buttonStyle(.plain)
                    .font(.title)
                    .foregroundStyle(.white, .white.tertiary)
            }
        }
    }
    
    /// Places the first five available covers of a manga in a statck.
    ///
    /// - Returns: a `ZStack` that places the first volume cover on top, and subsequent covers beneth it.
    func StackedCovers() -> some View {
        ZStack {
            ForEach(Array(model.getCoverDisplayURLs().enumerated().reversed()), id: \.offset) { index, url in
                CoverView(coverURL: url, scale: index == 0 ? 0.275 : index < 3 ? 0.25 : 0.225)
                    .layeredOffset(position: index + 1)
            }
        }
        .shadow(color: .black.opacity(0.5), radius: 30, y: 10)
    }
    
    /// Creates the the text that displays the bayesian weighted average, total number of folows,
    /// and comments for the displayed manga.
    ///
    /// - Returns: An `HStack` containing the appropriate text and an accompanying SF symbol.
    func StatisticsDetailView() -> some View {
        HStack(spacing: 1) {
            Label("\(String(format: "%.2f", model.statistics.bayesian ?? 0.0)) (\(model.statistics.totalRatings())) • ", systemImage: "star.fill")
            Label("\(model.statistics.follows) • ", systemImage: "bookmark.fill")
            Label("\(model.statistics.repliesCount ?? 0)", systemImage: "bubble.left.fill")
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.secondary)
    }
    
    /// Creates the buttons available on MangaDex for updating reading and followed status.
    ///
    /// - Returns: a group of styled buttons.
    func MangaToolBar() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                isShowingSheet.toggle()
            } label : {
                HStack(spacing: 4) {
                    Text("Book")
                        .fontWeight(.semibold)
                    
                    Image(systemName: "info.circle")
                        .font(.caption)
                }
            }
            
            Text(model.manga.status.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 10) {
                Button {
                    // TODO: nav to first unread chapter
                } label: {
                    Label("Read", systemImage: "book.pages")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                }
                .tint(.white.opacity(0.2))
                
                HStack(spacing: 10) {
                    Menu {
                        Picker("Reading Status", selection: $model.readingStatus) {
                            ForEach(ReadingStatus.allCases) { status in
                                Label(status.displayTitle, systemImage: status.systemImageName)
                                    .labelStyle(.titleOnly)
                                    .tint(status.color)
                            }
                        }
                    } label: {
                        Image(systemName: model.readingStatus.systemImageName)
                            .frame(minWidth: 20, maxWidth: .infinity)
                            .padding(.vertical, 5)
                    }
                    .tint(model.readingStatus.color)
                    
                    Button {
                        model.manga.isFollowed.toggle()
                        Task {
                            let status = await model.setFollowedStatus(to: model.manga.isFollowed)
                            model.manga.isFollowed = status
                        }
                    } label: {
                        Image(systemName: model.manga.isFollowed ? "bell.fill" : "bell.slash.fill")
                            .frame(minWidth: 20, maxWidth: .infinity)
                            .padding(.vertical, 5)
                    }
                    .tint(model.manga.isFollowed ? .blue : .gray)
                    
                    Button {
                        self.isPresented = true
                    } label: {
                        Image(systemName: "safari")
                            .frame(minWidth: 20, maxWidth: .infinity)
                            .padding(.vertical, 5)
                    }
                    .tint(.blue)
                }
                .padding(.vertical, 5)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 5)
        }
    }
    
    /// Combines the `FixedHeaderView`, `StackedCovers`, `StatisticsDetailView`, and `MangaToolBar`
    /// into a single view displayed above the displayed manga's chapters.
    ///
    /// - Returns: a `VStack` that combines mulptile view components.
    func CoversAndTitleView() -> some View {
        VStack(spacing: 15) {
            FixedHeaderView()
            
            StackedCovers()
                .padding(.top, -5)
            
            Text(model.manga.alternateTitle)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(.white)
            
            NavigationLink {
                // TODO: author view
            } label: {
                HStack(spacing: 6) {
                    Text(model.formattedAuthorNames)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundStyle(.white)
                    Image(systemName: "chevron.right")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
            .padding(.top, -10)
            
            StatisticsDetailView()
                .padding(.top, -10)
            
            MangaToolBar()
                .padding(15)
                .background(.white.opacity(0.2), in: .rect(cornerRadius: 20))
                .padding(.horizontal)
        }
        .foregroundStyle(.white)
        .padding(15)
        .background {
            BackgroundGradient(imageURL: model.covers["1"]!.imageURL256)
                .offset(y: 50)
        }
    }
    
    // TODO: add auto nav to reader view for all chapters in volume
    /// Creates a list of all available volumes and displays its cover art along side some basic information.
    ///
    /// - Returns: A `List` for all available volumes of the displayed manga.
    @ViewBuilder
    func VolumesList() -> some View {
        List(model.orderedVolumes, id: \.self) { volume in
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    CoverView(coverURL: model.covers[volume]!.imageURL, scale: 1 / 8)
                    
                    VStack(alignment: .leading) {
                        Text("\(model.manga.alternateTitle), Vol. \(volume)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(model.formattedAuthorNames)
                            .font(.callout)
                        Text("0%")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Menu {
                    Section {
                        ShareLink(item: URL(string: "https://mangadex.org/title/\(model.manga.id.uuidString.lowercased())")!) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                    
                    // TODO: add more actions
                    Section {
                        Button {
                            
                        } label: {
                            Label("Mark as Read", systemImage: "checkmark.circle")
                        }
                    }
                    
                    // TODO: check for download
                    Section {
                        Button {
                            
                        } label: {
                            Label("Download", systemImage: "arrow.down.circle")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .frame(minWidth: 90)
            }
        }
        .scrollDisabled(true)
        .listStyle(.plain)
        .scrollIndicators(.never)
        .frame(height: CGFloat(model.covers.keys.count * 80) + CGFloat(model.covers.keys.count < 4 ? 200 : 0), alignment: .top)
    }
    
    /// Creates a list of all available chapters and displays its title, and scanlation group.
    ///
    /// - Returns: A `List` for all available chapters of the displayed manga.
    @ViewBuilder
    func ChaptersList() -> some View {
        List(model.orderedChapters, id: \.self) { volume in
            Section(header: Text(volume == "No Volume" ? volume : "Volume \(volume)")) {
                ForEach(model.chapters[volume]!) { chapter in
                    NavigationLink {
                        ReaderView(chapter: chapter, title: chapter.fullTitle)
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Image(systemName: chapter.hasBeenRead ? "eye.slash" : "eye")
                                Image(systemName: "person.2")
                            }
                            
                            VStack(alignment: .leading) {
                                Text(chapter.fullTitle)
                                Text(chapter.scanlationGroup?.name ?? "No group")
                            }
                            .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .scrollDisabled(true)
        .listStyle(.plain)
        .scrollIndicators(.never)
        /// Calulates the minimum frame size needed so the this list can be displayed in a scrollview.
        /// [Source](https://www.itecheverything.com/post/beyond-the-limitations-of-swiftui-list-inside-a-scrollview)
        .frame(height: (minRowHeight + 20) * CGFloat(model.totalChapters) + CGFloat(model.totalVolumes * 55) + CGFloat(model.totalChapters < 4 ? 200 : 0), alignment: .top)
    }
    
    /// Contains the additional info that is normally found on a given manga's page on MangaDex.
    func MangaInfoSheet() -> some View {
        ScrollView(.vertical) {
            VStack(spacing: 15) {
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Description")
                        .fontWeight(.semibold)
                    
                    Text((try? AttributedString(
                        markdown: model.manga.summary["en"] ?? "",
                        options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(model.manga.summary["en"] ?? "")
                    )
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                
            }
            .offset(y: 105)
            .padding(.horizontal, 25)
        }
        .scrollIndicators(.never)
        .overlay(alignment: .top) {
            HStack(alignment: .top, spacing: 15) {
                CoverView(coverURL: model.covers[model.latestVolume]!.imageURL512, scale: 1 / 10)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Manga Details")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Book")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    isShowingSheet.toggle()
                } label: {
                    Image(systemName: "multiply.circle.fill")
                }
                .font(.title)
                .foregroundStyle(.secondary, .tertiary)
            }
            //            .background(.ultraThinMaterial)
            .padding(20)
        }
    }
}

#if DEBUG
private extension Bundle {
    func decode<T: Decodable>(from file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        RFC3339DateFormatter.timeZone = TimeZone.current
        
        decoder.dateDecodingStrategy = .formatted(RFC3339DateFormatter)
        
        do {
            return try decoder.decode(Wrapper<T>.self, from: data).data
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

#Preview {
    func setup() -> PersistentManga {
        let previewManga: Manga = Bundle.main.decode(from: "Laid Back Camp Preview.json")
        let previewCovers: [Cover] = Bundle.main.decode(from: "Laid Back Camp Covers Preview.json")
        let previewChatpers: [Chapter] = Bundle.main.decode(from: "Laid Back Camp Chapter Feed Preview.json")
        
        let displayedManga: PersistentManga = .init(from: previewManga, readingStatus: .plan_to_read)
        displayedManga.authors = previewManga.author.map { .init(from: $0) }
        displayedManga.chapters = previewChatpers.map { .init(from: $0) }
        displayedManga.covers = previewCovers.map { .init(from: $0, urlPath: displayedManga.id)}
        return displayedManga
    }
    
    return MangaView(manga: setup())
}
#endif
