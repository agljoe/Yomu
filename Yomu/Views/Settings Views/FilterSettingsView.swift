//
//  FilterSettingsView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-15.
//

import SwiftUI

struct FilterSettingsView: View {
    @State var sortOptions = ["Best Match", "Latest Upload", "Oldest Upload", "Title Ascending", "Title Descending", "Highest Rating", "Lowest Rating", "Most Follows", "Fewest Follows", "Recently Added", "Oldest Added", "Year Ascending", "Year Descending"] // could make tag
    
    @State var contentRatings = ["Safe", "Suggestive", "Erotica", "Pornographic"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Sort by", selection: $sortOptions) {
                        ForEach(sortOptions, id: \.self) {
                            Text("\($0)")
                        }
                    }
                }
                
                Section {
                    NavigationLink {
                        FilterTagsView()
                    } label: {
                        Text("Tags")
                    }
                    
                    Text("Content Rating")
                    
                    Text("Magazine Demographic")
                }
                
                Section {
                    
                    Text("Authors")
                    
                    Text("Artists")
                    
                }
                    
                Section {
                    Text("Publication Year")
                    
                    Text("Publication Status")
                }
                    
                Section {
                    Text("Original Languages")
                    
                    Text("Has Translated Chapters")
                }
                
                Section {
                    
                    
                    Button("Reset Filters", role: .destructive) {
                        // set all serch filters to default values
                        // sort by: none
                        // filter tags: include any, exclude none
                        // content rating: any except pornographic
                        // demographic: any
                        // authors: any GET/author w/ query for name
                        // artists: any GET/author w/ query for name
                        // original languages: all
                        // publication year: any
                        // publication status: any
                        // has translated chapters: false, filter for available translated languages
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FilterSettingsView()
}
