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
    
    let data: [UUID] = [
        UUID(uuidString: "9faba8cf-60df-4894-9370-22571592c8d3")!
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(data, id: \.self) { item in
                        NavigationLink {
                          
                        } label: {
                            Text("Test")
                        }
                    }
                }
                .padding()
                .scrollIndicators(.hidden)
                .navigationTitle("Library")
            }
            .searchable(text: $query, prompt: Text("Search Library"))
        }
    }
}

func getFollowedManga(limit: Int, offset: Int) async throws {
    
}

#Preview {
    LibraryView()
}
