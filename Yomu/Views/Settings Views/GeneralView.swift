//
//  GeneralView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-13.
//

import SwiftUI

struct GeneralView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink("About", destination: AboutView())
                }
                
                Section {
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
