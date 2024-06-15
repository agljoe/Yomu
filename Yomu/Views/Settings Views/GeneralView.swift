//
//  GeneralView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-13.
//

import SwiftUI

struct GeneralView: View {
    @State private var defaultLanguage = ["English", "French", "Japanese", "Chinese"] //update for all languages
    
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
