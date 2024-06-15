//
//  LibraryView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import SwiftUI

struct MangaCoverURL: Identifiable {
    let title: String
    var id: String { title }
    let urlString: String
}

struct LibraryView: View {
    @State private var query = ""
    
    let data: [MangaCoverURL] = [
        MangaCoverURL(title: "Warui ga Watashi wa Yuri ja nai", urlString: "https://uploads.mangadex.org/covers/8f3e1818-a015-491d-bd81-3addc4d7d56a/26dd2770-d383-42e9-a42b-32765a4d99c8.png"), MangaCoverURL(title: "[Oshi no Ko]", urlString: "https://uploads.mangadex.org/covers/296cbc31-af1a-4b5b-a34b-fee2b4cad542/6a60b4c5-1c23-4106-8500-d9a478db9b0e.jpg")
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(data) { item in
                        AsyncImage(url:  URL(string: item.urlString)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .frame(height: 200)

                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .scrollIndicators(.hidden)
            .navigationTitle("Library")
        }
        .searchable(text: $query, prompt: Text("Search Library"))
    }
}

#Preview {
    LibraryView()
}
