//
//  LibraryView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import SwiftUI

struct LibraryView: View {
    @State private var query = ""
    
    var body: some View {
        NavigationStack {
            Button("Get Manga") {
                Task {
                    try await getManga(id: "dfffa880-4154-40d1-abd2-0dff94248908")
                }
            }
            
            Button("Get Chapter") {
                Task {
//                    try await getVolumesAndChapters(id: "80fa0d7b-514c-4a44-9050-d39151ec2ebc")
                }
            }
                .navigationTitle("Library")
        }
        .searchable(text: $query, prompt: Text("Search Library"))
    }
}

#Preview {
    LibraryView()
}
