//
//  AppearanceView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-13.
//

import SwiftUI

struct AppearanceView: View {
    @AppStorage("enableDarkMode") var enableDarkMode: Bool = false
    @AppStorage("displayedColumns") var displayedColumns: Int = 2
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Dark Mode", isOn: $enableDarkMode)
                }
                
                Section {
                    Stepper(value: $displayedColumns, in: 1...5) {
                        Text("Displayed Columns: \(displayedColumns)")
                    }
                }
            }
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AppearanceView()
}
