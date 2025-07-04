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
    
    @State var colums = Array(repeating: GridItem(.flexible()), count: UserDefaults.standard.integer(forKey: "displayedColumns") < 2 ? 2 : UserDefaults.standard.integer(forKey: "displayedColumns"))
    
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
                        .frame(width: 0, height: 0)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .padding()
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
