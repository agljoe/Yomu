//
//  SearchSettingsView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-13.
//

import SwiftUI

struct SearchSettingsView: View {
    @State var saveSearchFilters = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        FilterSettingsView()
                    } label: {
                        HStack {
                            Text("Filters")
                        }
                    }
                }
                
                Section {
                    Toggle("Save Filters", isOn: $saveSearchFilters)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SearchSettingsView()
}
