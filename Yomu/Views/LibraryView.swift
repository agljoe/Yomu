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
            Text("Login to view your library")
                .navigationTitle("Library")
        }
        .searchable(text: $query, prompt: Text("Search Library"))
    }
}

#Preview {
    LibraryView()
}
