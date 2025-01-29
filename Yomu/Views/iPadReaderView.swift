//
//  iPadReaderView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-27.
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

struct PortraitReaderView: View {
    @State var chapterComponents: AtHomeChapterComponents
    
    var body: some View {
//        GeometryReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(Array(chapterComponents.data.enumerated()), id: \.offset) { index, page in
                        PageView(imageUrl: urlBuilder(for: chapterComponents, page: page))
                            .scaleEffect(x: -1)
//                            .frame(width: proxy.size.width, alignment: .center)
//                            .frame(width: proxy.size.width, height: proxy.size.height)
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
//        }
    }
}

struct LandscapeReaderView: View {
    @State var chapterComponents: AtHomeChapterComponents
    
    var body: some View {
        Text("Landscape Reader View")
    }
}

struct iPadReaderView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var orientation = UIDevice.current.orientation
    @State private var navBarVisisble: Bool = true
    @State var chapterComponents: AtHomeChapterComponents = AtHomeChapterComponents()
    
    let chapterId: UUID
    let title: String
    
    var body: some View {
        NavigationStack {
            Group {
                if orientation.isPortrait {
                    PortraitReaderView(chapterComponents: chapterComponents)
                } else if orientation.isLandscape {
                    LandscapeReaderView(chapterComponents: chapterComponents)
                } else if orientation.isFlat {
                    Text("Flat")
                } else {
                    Text("Unknown")
                }
            }
            .onRotate { newOrientation in
                orientation = newOrientation
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
        .task {
            do {
                chapterComponents = try await getChapterData(for: chapterId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    iPadReaderView(chapterId: UUID(uuidString: "ff34cbc6-2c68-40f1-910a-c0e6fbd5adaf")!, title: "Ch. 1 - Mt. Fuji and Cup Ramen")
}
