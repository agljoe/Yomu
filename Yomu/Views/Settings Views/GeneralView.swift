//
//  GeneralView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-13.
//

import SwiftUI

struct GeneralView: View {
    @State private var defaultLanguage = ["English", "French", "Japanese", "Chinese"] //update for all languages
    @State private var cacheSize = Double(URLCache.shared.currentDiskUsage) / (1024 * 1024)
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink("About", destination: AboutView())
                }
                
                Section {
                    Picker("Language", selection: $defaultLanguage) {
                        ForEach(defaultLanguage, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        URLCache.shared.removeAllCachedResponses()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear Cache \(cacheSize) mb")
                        }
                    }
                    
                    Button("Reset", role: .destructive) {
                        //reset app
                    }
                }
                
            }
            .navigationTitle("General")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    GeneralView()
}
