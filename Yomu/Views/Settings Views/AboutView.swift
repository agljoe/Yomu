//
//  AboutView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-13.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Version")
                        
                        Spacer()
                        
                        Text("dev")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        
                        Spacer()
                        
                        Text("0.01")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link("Github", destination: URL(string: "https://github.com/agljoe/Yomu/tree/main/Yomu")!)
                }
                
                Section {
                    HStack {
                        Text("Downloaded Manga")
                        
                        Spacer()
                        
                        Text("0 GB")
                            .foregroundStyle(.secondary)
                    }
                    
                    Button(role: .destructive) {
                        // implement delete downloaded
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Remove Downloaded Manga")
                        }
                    }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AboutView()
}
