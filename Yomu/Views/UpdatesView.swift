//
//  UpdatesView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import SwiftUI

struct MangaUpdateView: View {
    var body: some View {
        if #available(iOS 15.0, *) {
            if UIDevice.current.systemName == "iPadOS" {
                HStack {
                    AsyncImage(url: URL(string: "https://uploads.mangadex.org/covers/8f3e1818-a015-491d-bd81-3addc4d7d56a/26dd2770-d383-42e9-a42b-32765a4d99c8.png")) { image in // load each image for updates from last day then load last week... etc
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .scaledToFit()
                    .frame(height: 255, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .padding(.leading)
                    
                    VStack(alignment: .leading) {
                        Text("Manga Title")
                            .padding(.top, 30)
                            .font(.title2)
                        
                        Rectangle()
                            .frame(height: 1)
                            .padding(.trailing)
                            .foregroundStyle(.secondary)
                        List {
                            Text("Ch. 1")
                        }
                        .listStyle(.plain) //fix this background color
                        .padding(.trailing)
                    }
                }
                .background(
                    .secondary
                        .opacity(0.3)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(height: 300)
                .padding(.horizontal)
                .padding(.vertical, 5)
            } else {
                HStack {
                    AsyncImage(url: URL(string: "https://uploads.mangadex.org/covers/8f3e1818-a015-491d-bd81-3addc4d7d56a/26dd2770-d383-42e9-a42b-32765a4d99c8.png")) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .scaledToFit()
                    .frame(height: 144.5, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .padding(.leading)
                    
                    VStack(alignment: .leading) {
                        Text("Manga Title")
                            .padding(.top)
                            .font(.title3)
                        
                        Rectangle()
                            .frame(height: 1)
                            .padding(.trailing)
                            .foregroundStyle(.secondary)
                        List {
                            Text("Ch. 1")
                        }
                        .listStyle(.plain) //fix this background color
                        .padding(.trailing)
                    }
                }
                .background(
                    .secondary
                        .opacity(0.3)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(height: 170)
                .padding(.horizontal)
            }
        }
    }
}

struct UpdatesView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(0..<5) { i in
                    MangaUpdateView()
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Updates")
        }
    }
}

#Preview {
    UpdatesView()
}
