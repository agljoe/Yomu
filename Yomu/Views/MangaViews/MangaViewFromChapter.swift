//
//  MangaView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-13.
//

import Foundation
import SwiftUI

struct MangaView: View {
    @State var cover: Cover = Cover()
    @State private var manga: Manga = Manga()
    @State private var statistics: MangaStatistics = MangaStatistics()
    @State private var chapters: [Chapter] = []
    @State private var markers: [UUID] = []
    @State private var isLoading: Bool = false
    
    let id: UUID
    
    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView()
            } else {
                ScrollView {
                    //                    ZStack {
                    //                        GeometryReader { proxy in
                    //                            CachedAsyncImage(url: URL(string: "https://uploads.mangadex.org/covers/\(id.uuidString.lowercased())/\(cover.fileName).512.jpg")) { image in
                    //                                image
                    //                                    .resizable()
                    //                                    .aspectRatio(contentMode: .fill)
                    //                            } placeholder: {
                    //                                ProgressView()
                    //                            }
                    //                            .frame(width: proxy.size.width, height: 225, alignment: .top)
                    //                        }
                    //                        .frame(height: 225, alignment: .top)
                    //                        .clipped()
                    //                        .blur(radius: 3)
                    //                        .brightness(-0.11)
                    //                        .offset(y: -220)
                    
                    
                    VStack {
                        HStack {
                            CachedAsyncImage(url: URL(string: "https://uploads.mangadex.org/covers/\(id.uuidString.lowercased())/\(cover.fileName).512.jpg")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            LazyVStack(alignment: .leading) {
                                Text(manga.title["en"] ?? "")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .backgroundStyle(.white)
                                    .lineLimit(2)
                                
                                Text(manga.altTitles.first(where: { $0.keys.contains("en") })?.values.first ?? "")
                                    .font(.title3)
                                    .backgroundStyle(.white)
                                
                                ScrollView(.horizontal) {
                                    List(manga.author ?? []) {
                                        Text($0.name)
                                            .backgroundStyle(.white)
                                    }
                                    .listStyle(.plain)
                                    .listRowBackground(Color.clear)
                                }
                                .scrollIndicators(.never)
                                .scrollContentBackground(.hidden)
                            }
                            .offset(y: -45)
                        }
                        .padding([.top], 35)
                        .frame(alignment: .center)
                        
                        VStack(alignment: .leading) {
                            Text(try! AttributedString(markdown: manga.description["en"] ?? ""))
                            
                            VolumesAndChaptersListView(volumes: organizeChapters(chapters, markers))
                        }
                    }
                }
            }
        }
        //        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(manga.title["en"] ?? "")
        .task {
            self.isLoading = true
            do {
                self.manga = try await getManga(id)
                self.statistics = try await getStatisticsFor(manga: id)
                self.chapters = try await getChapters(for: id)
                if cover.id.uuidString == "00000000-0000-0000-0000-000000000000" {
                    self.cover = try await getCovers(for: [id]).first!
                }
            } catch {
                print(error.localizedDescription)
                print(error)
            }
            self.isLoading = false
        }
    }
}

#Preview {
    MangaView(id: UUID(uuidString: "9faba8cf-60df-4894-9370-22571592c8d3")!)
}
