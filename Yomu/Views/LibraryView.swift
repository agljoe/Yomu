//
//  LibraryView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import SwiftData
import SwiftUI

struct LibraryView: View {
    @Environment(\.modelContext) var context
    @State private var model = Model()
    
    
    var body: some View {
        NavigationStack {
            Text("coming soon")
        }
        .navigationTitle(Text("Library"))
        .searchable(text: .constant(""))
    }
}

extension LibraryView {
    @Observable
    class Model {
        private(set) var manga: [Manga] = []
        private(set) var statuses: [String: String] = [:]
        private(set) var isLoading: Bool = false
        
        
        @MainActor
        func fetchLibrary() async throws {
            guard !isLoading else { return }
            defer { isLoading = false }
            isLoading = true
            
            async let statuses = AllMangaReadingStatusRequest().execute()
            let _ = try await statuses.keys
            
            
            
        }
    }
}

#Preview {
    LibraryView()
}
