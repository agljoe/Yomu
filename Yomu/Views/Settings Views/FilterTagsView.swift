//
//  FilterTagsView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-17.
//

import SwiftData
import SwiftUI

struct TagButton: View {
    @State var filter: FilterTag
    @State var buttonColor = Color.noSelection
    
    var body: some View {
        Button(filter.tag.name) {
            updateSelection(color: buttonColor)
        }
        .frame(width: 45, height: 25)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(buttonColor)
        .foregroundStyle(.buttonText)
    }
    
    func updateSelection(color: Color) { // could be better
        switch color {
        case .noSelection:
            buttonColor = Color.includes
            filter.isIncluded = false
            filter.isExcluded = false
        case .includes:
            buttonColor = Color.excludes
            filter.isIncluded = true
            filter.isExcluded = false
        case .excludes:
            buttonColor = Color.noSelection
            filter.isIncluded = false
            filter.isExcluded = true
        default:
            buttonColor = Color.noSelection
            filter.isIncluded = false
            filter.isExcluded = false
        }
    }
}

struct FilterTagsView: View {
    @Environment(\.modelContext) var modelContext
    @Query var tags: [FilterTag]
    
    @State private var path = [FilterTag]()
    @State private var inclusionMode = ["And", "Or"]
    @State private var exclusionMode = ["And", "Or"]
    @State private var includeGore = false
    @State private var includeSexualViolence = false
    
    var body: some View {
        NavigationStack(path: $path) {
            Form {
                Section {
                    ForEach(path.filter { $0.tag.group == "format" }) { tag in
                        TagButton(filter: tag)
                    }
                }
                
                Section(header: Text("Content")) {
                    Toggle("Gore", isOn: $includeGore)
                    // onChange add to query
                    
                    Toggle("Sexual Violence", isOn: $includeGore)
                    //onChange add to query
                }
                .textCase(.none)
                
                Section {
                    Picker("Inclusion Mode", selection: $inclusionMode) {
                        ForEach(inclusionMode, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    
                    Picker("Exclusion Mode", selection: $exclusionMode) {
                        ForEach(exclusionMode, id: \.self) {
                            Text("\($0)")
                        }
                    }
                }
                
                Section {
                    Button("Reset Tags", role: .destructive) {
                        // remove all selections
                        // inclusion mode = AND
                        // exclusion mode = OR
                    }
                }
            }
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func loadTags() async throws {
        // try to only call once
        
        let tags = try await getTags()
        
        for tag in tags {
            let filterTag = FilterTag(tag: tag, isIncluded: false, isExcluded: false)
            modelContext.insert(filterTag)
            path.append(filterTag)
        }
    }
}


#Preview {
    FilterTagsView()
}
