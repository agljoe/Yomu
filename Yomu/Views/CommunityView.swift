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
        }
    }
}

#Preview {
    CommunityView()
}
