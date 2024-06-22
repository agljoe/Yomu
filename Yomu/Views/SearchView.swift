//
//  SearchView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var showingSheet = false
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    Button("Test") {
                        var components = URLComponents()
                        components.scheme = "https"
                        components.host = "api.mangadex.org"
                        components.path = "/manga/"
                        components.query = "includes[]=author&includes[]=artist"
                        
                        print(components)
                    }
                }
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Search")
            .toolbar(id: "options") {
                ToolbarItem(id: "filters", placement: .primaryAction) {
                    Button {
                        showingSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .toolbarRole(.navigationStack)
                }
            }
            
        }
        .sheet(isPresented: $showingSheet) {
            FilterSettingsView()
        }
    }
}

#Preview {
    SearchView()
}
