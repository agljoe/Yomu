//
//  CommunityView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import SwiftUI

struct CommunityView: View {
    var body: some View {
        VStack {
            Text("Coming Soon")
            
            Button("Get Tags") {
                Task {
                    try await getTags()
                }
            }
            
            Button("Health Check") {
                Task {
                    try await healthCheck()
                }
            }
            
            Button("Get Cover") {
                Task {
                    try! await getCover(id: "dfffa880-4154-40d1-abd2-0dff94248908") 
                }
            }
            
            Button("Try JSON Decoder") {
                Task {
                    try! await getManga(id: "dfffa880-4154-40d1-abd2-0dff94248908")
                }
            }
        }
    }
}

#Preview {
    CommunityView()
}
