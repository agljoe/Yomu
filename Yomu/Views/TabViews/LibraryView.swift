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

///
struct LibraryView: View {
    @Environment(\.database) var database
    @Query(sort: \PersistentManga.readingStatus) var library: [PersistentManga]
    
//    @State private var model = Model()
    
    @State var colums = Array(repeating: GridItem(.flexible(), spacing: 15), count: UserDefaults.standard.integer(forKey: "displayedColumns") < 2 ? 2 : UserDefaults.standard.integer(forKey: "displayedColumns"))
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: colums, spacing: 15) {
                    ForEach(library) { manga in
                        NavigationLink {
                            MangaView(manga: manga)
                        } label : {
                            VStack {
                                CoverView(
                                    coverURL: manga.covers.sorted(by: { Double($0.volume ?? "0") ?? 0 > Double($1.volume ?? "0") ?? 0 }).first!.imageURL,
                                    scale: 1 / 3)
                                Text(manga.title)
                                    .foregroundStyle(.gray)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle(Text("Library"))
        }
        .searchable(text: .constant(""))
//        .refreshable { Task { try? await model.updateLibrary() } }
    }
}

#Preview {
    LibraryView()
}
