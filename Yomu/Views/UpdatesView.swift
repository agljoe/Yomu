//
//  UpdatesView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import SwiftUI

struct MangaUpdateView: View {
    @State var coverURL: String
    
    var body: some View {
        if #available(iOS 15.0, *) {
            if UIDevice.current.systemName == "iPadOS" {
                HStack {
                    AsyncImage(url: URL(string: coverURL)) { image in // load each image for updates from last day then load last week... etc
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .scaledToFit()
                    .frame(height: 300, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(10)
                    
                    VStack(alignment: .leading) {
                        Text("Manga Title")
                            .padding(.top, 10)
                            .font(.title)
                        
                        Rectangle()
                            .frame(height: 1)
                            .padding(.trailing)
                            .foregroundStyle(.secondary)
                        
                       Text("Ch 1")
                        
                        Spacer()
                    }
                }
                .background(
                    .thinMaterial
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(height: 300)
                .padding()
            } else {
                HStack {
                    AsyncImage(url: URL(string: coverURL)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                            .padding()
                    }
                    .scaledToFit()
                    .frame(height: 150, alignment: .leading)
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading) {
                        Text("Manga Title")
                            .padding(.top, 10)
                            .font(.title3)
                        
                        Rectangle()
                            .frame(height: 1)
                            .padding(.trailing)
                            .foregroundStyle(.secondary)
                        
                        Text("Ch 1")
                        
                        Spacer()
                    }
                }
                .background(
                    .thinMaterial
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(height: 150)
                .padding(7)
            }
        }
    }
}

struct UpdatesView: View {
    let covers = [
        "https://uploads.mangadex.org/covers/8f3e1818-a015-491d-bd81-3addc4d7d56a/26dd2770-d383-42e9-a42b-32765a4d99c8.png","https://uploads.mangadex.org/covers/296cbc31-af1a-4b5b-a34b-fee2b4cad542/6a60b4c5-1c23-4106-8500-d9a478db9b0e.jpg", "https://mangadex.org/covers/c9aaa96b-36fc-41c5-a427-6e39c26b7720/fb65b75e-9e45-4aa6-929c-9e35206fd5cc.jpg", "https://mangadex.org/covers/9d3d3403-1a87-4737-9803-bc3d99db1424/a4c67b90-2f91-43ea-ad1f-c275c4509cde.jpg", "https://mangadex.org/covers/30b89356-952c-4a72-9d8c-cf44147e881a/a53438ab-4e54-4c36-9e73-7ae11f748c10.jpg"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(0..<5) { i in
                    MangaUpdateView(coverURL: covers[i])
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
