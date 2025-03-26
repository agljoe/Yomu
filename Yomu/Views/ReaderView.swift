//
//  ReaderView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-21.
//

import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

struct SizeReader: ViewModifier {
    @Binding var size: CGSize
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { proxy in
                Color.clear
                    .onAppear{
                        size = proxy.size
                    }
            }
            )
    }
}

extension View {
    func readSize(size: Binding<CGSize>) -> some View {
        modifier(SizeReader(size: size))
    }
}

struct PageView: View {
    let imageUrl: URL
    
    var body: some View {
        ChapterPageImage(source: imageUrl)
            .aspectRatio(contentMode: .fit)
            .ignoresSafeArea()
    }
}

struct DoublePageView: View {
    let imageUrl: URL
    @State var pageSize: CGSize = .zero
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    
    var body: some View {
        ChapterPageImage(source: imageUrl)
            .aspectRatio(contentMode: .fit)
            .scaledToFit()
            .readSize(size: $pageSize)
            .onChange(of: pageSize) {
                width = pageSize.width
                height = pageSize.height
            }
    }
}

struct ReaderView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var orientation = UIDevice.current.orientation
    @State private var navBarVisisble: Bool = true
    @State private var chapterComponents: AtHomeChapterComponents = AtHomeChapterComponents()
    @State private var pageWidths = [CGFloat]()
    @State private var pageHeights = [CGFloat]()
    let chapterId: UUID
    let title: String
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack {
                        if orientation.isLandscape {
                            ForEach(Array(chapterComponents.data.enumerated()), id: \.offset) { index, page in
                                DoublePageView(imageUrl: urlBuilder(for: chapterComponents, page: page), width: $pageWidths[index], height: $pageHeights[index])
                                    .scaleEffect(x: -1)
                                    .frame(width: pageWidths[index] > pageHeights[index] ? proxy.size.width : proxy.size.width/2, height: proxy.size.height, alignment: .center)
                                    .padding()
                                    .containerRelativeFrame(.horizontal, count:  pageWidths[index] > pageHeights[index] ? 1 : 2, spacing: 0)
                            }
                            .onAppear {
                                print("Landscape")
                            }
                        } else {
                            ForEach(Array(chapterComponents.data.enumerated()), id: \.offset) { index, page in
                                PageView(imageUrl: urlBuilder(for: chapterComponents, page: page))
                                    .scaleEffect(x: -1)
                                    .frame(width: proxy.size.width, alignment: .center)
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .safeAreaPadding(0)
                                    .containerRelativeFrame(.horizontal, count: 1,  spacing: 0)
                            }
                            .onAppear {
                                print("Portrait")
                            }
                            
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.never)
                .flipsForRightToLeftLayoutDirection(true)
                .environment(\.layoutDirection, .rightToLeft)
                .task {
                    do {
                        chapterComponents = try await getChapterData(for: chapterId)
                        pageWidths = Array(Array(repeating: CGFloat.zero, count: chapterComponents.data.count))
                        pageHeights = Array(Array(repeating: CGFloat.zero, count: chapterComponents.data.count))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .ignoresSafeArea()
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
    
    guard let url = components.url else { throw MDApiError.invalidURL(context: "Url could not be constructed from components: \(components.string ?? "Unknown")") }
    
    let data = try await get(from: url)
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
        let _ = try await post(at: URL(string: "https://api.mangadex.network/report")!, value: "application/json", content: data)
    } catch {
        print(error.localizedDescription)
    }
}

#Preview {
    ReaderView(chapterId: UUID(uuidString: "ff34cbc6-2c68-40f1-910a-c0e6fbd5adaf")!, title: "Ch. 1 - Mt. Fuji and Cup Ramen")
}
