//
//  SearchView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        VStack {
            Button("Get Manga") {
                Task {
                    try await getManga(id: "30b89356-952c-4a72-9d8c-cf44147e881a")
                }
            }
            
            Button("Get Another Manga") {
                Task {
                    try await getManga(id: "dfffa880-4154-40d1-abd2-0dff94248908")
                }
            }
            
            Button("Get Author") {
                Task {
                    try await getAuthor(id: "dbe4cbfe-81dd-4766-a658-ad006ad5a1d7")
                }
            }
        }
    }
}

#Preview {
    SearchView()
}
