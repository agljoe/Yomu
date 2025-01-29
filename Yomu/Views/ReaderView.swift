//
//  ReaderView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-21.
//

import SwiftUI

struct PageView: View {
    let imageUrl: URL
    
    var body: some View {
        RemoteImage(source: imageUrl)
            .aspectRatio(contentMode: .fit)
    }
}

struct ReaderView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navBarVisisble: Bool = true
    @State private var chapterComponents: AtHomeChapterComponents = AtHomeChapterComponents()
    let chapterId: UUID
    let title: String
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(Array(chapterComponents.data.enumerated()), id: \.offset) { index, page in
                            PageView(imageUrl: urlBuilder(for: chapterComponents, page: page))
                                .scaleEffect(x: -1)
                                .frame(width: proxy.size.width, alignment: .center)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                        }
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                    }
                    .ignoresSafeArea()
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.never)
                .flipsForRightToLeftLayoutDirection(true)
                .environment(\.layoutDirection, .rightToLeft)
                .task {
                    do {
                        chapterComponents = try await getChapterData(for: chapterId)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .onTapGesture {
                navBarVisisble.toggle()
            }
            .navigationTitle(title)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar, .bottomBar)
            .toolbarBackground(.visible, for: .navigationBar, .bottomBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar(navBarVisisble ? .visible: .hidden, for: .navigationBar, .bottomBar)
            .statusBarHidden(!navBarVisisble)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("chapters")
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        //
                    } label: {
                        Text("Bottom bar")
                    }
                }
            }
        }
    }
}

func getChapterData(for chapterId: UUID) async throws -> AtHomeChapterComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.mangadex.org"
    components.path = "/at-home/server/\(chapterId.uuidString.lowercased())"
    //TODO: force port 443 if selected
    
    guard let url = components.url else { throw MDApiError.badRequest }
    
    let data = try await get(for: url)
    let chapter = try JSONDecoder().decode(AtHomeChapterComponents.self, from: data)
    
    return chapter
}

func urlBuilder(for chapter: AtHomeChapterComponents, page: String) -> URL {
    return URL(string: "\(chapter.baseUrl)/data/\(chapter.hash)/\(page)")!
}

func atHomeReport(url: String, response: URLResponse, duration: Int) async {
    if url.contains("mangadex.org") { return }
    
    guard let httpResponse = response as? HTTPURLResponse else { return }
    
    let headers = httpResponse.allHeaderFields
    
    struct Report: Encodable {
        let url: String
        let success: Bool
        let cached: Bool
        let bytes: Int
        let duration: Int
    }
    
    let report = Report(url: url, success: httpResponse.statusCode == 200 ? true : false, cached: (headers["X-Cache"] as? String)?.contains("HIT") ?? false, bytes: headers["Content-Length"] as? Int ?? 0, duration: duration)
    
    do {
        let data = try JSONEncoder().encode(report)
        let _ = try await post(url: URL(string: "https://api.mangadex.network/report")!, value: "application/json", content: data)
    } catch {
        print(error.localizedDescription)
    }
    
}

#Preview {
    ReaderView(chapterId: UUID(uuidString: "ff34cbc6-2c68-40f1-910a-c0e6fbd5adaf")!, title: "Ch. 1 - Mt. Fuji and Cup Ramen")
}
