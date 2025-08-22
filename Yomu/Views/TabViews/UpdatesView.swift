//
//  UpdatesView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import MangaDexAPIKit
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
        var components = URLComponents()
        components.scheme = "https"
        components.host = MangaDexAPIBaseURL.uploads.rawValue
        components.path = "/covers/\(manga.id.uuidString.lowercased())/\(cover.fileName).\(UserDefaults.standard.bool(forKey: "dataSaver") ? "256" : "512").jpg"
        return components.url!
    }
}

/// Used to sort updates so the newest is presented frist.
extension Update: Comparable {
    /// Indicateds which update was more recently readable.
    ///
    /// - Parameters:
    ///   - lhs: an update to be compared.
    ///   - rhs: another update to be compared.
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
    ///   - lhs: an update to be compared.
    ///   - rhs: another update to be compared.
    ///
    /// - Returns: True if both the lhs and rhs were readable at the same time.
    static func == (lhs: Update, rhs: Update) -> Bool {
        return lhs.chapters.first!.readableAt == rhs.chapters.first!.readableAt
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
//            ReaderView(chapter: chapter, title: "Ch. \(chapter.chapter ?? "0") \(chapter.title ?? "")")
            /// Fixes a weird animation bug that occurs when new views that cover the tab bar are pushed onto the nagivation stack.
//                .navigationBarBackButtonHidden(true)
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
//                MangaView(manga: update.manga)
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
    @State private var model = UpdatesViewModel()
    
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
                        .onAppear {
                            Task {
                                do {
                                    try await model.fetchUpdates()
                                } catch let error {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                }
            }
            .overlay(Group { if model.isLoading { ProgressView() } })
            .scrollIndicators(.never)
            .refreshable {
                Task {
                    do {
                        try await model.fetchUpdates()
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            .navigationTitle("Updates")
        }
    }
}

#Preview {
    UpdatesView()
}
