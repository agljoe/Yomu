//
//  ReaderView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-21.
//

import MangaDexAPIKit
import SwiftUI

/// Modifies the reader based on the current device rotation.
struct DeviceRotationViewModifier: ViewModifier {
    /// A closure that wraps the device orientation..
    let action: (UIDeviceOrientation) -> Void
    
    /// Notifies content when the view is rotated.
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    /// Sets the view modifier to the device's current orientation.
    ///
    /// - Parameter action: an escaping closure that exectutes when a device roatation is detected.
    ///
    /// - Returns: The view this modifier was placed on, updating its device roataion modifier with action.
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

/// A single page of a manga.
struct PageView: View {
    /// The url  his page's image is downloaded form.
    let imageUrl: URL
    
    /// Displays a single page scaled to fit the user's device.
    var body: some View {
        ChapterPageImage(source: imageUrl)
            .aspectRatio(contentMode: .fit)
            .ignoresSafeArea()
    }
}

/// A single page of a manga that is displayed beside another page.
///
/// This view stores the size of its page.
struct DoublePageView: View {
    /// The url  his page's image is downloaded form.
    let imageUrl: URL
    
    /// The size of this image, initalized to zero since pages need to load asynchronously.
    @State var pageSize: CGSize = .zero
    
    /// The wdith of this page.
    @Binding var width: CGFloat
    
    /// The height of this page.
    @Binding var height: CGFloat
    
    /// Displays a single page scaled to fit next to another page, and updates its size variables
    /// passed by its parent view.
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

// TODO: make custom view for page diplays

struct ReaderView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var orientation = UIDevice.current.orientation
    @State private var navBarVisisble: Bool = true
    @State var model: ReaderViewModel
    
    let title: String
    
    init(chapter: Chapter, title: String) {
        self.title = title
        self.model = ReaderViewModel(chapter: chapter)
        self._model = .init(initialValue: model)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack {
                        if orientation.isLandscape {
                            ForEach(
                                Array(UserDefaults.standard.bool(
                                    forKey: "dataSaver") ? model.atHomeComponents.dataSaver.enumerated() : model.atHomeComponents.data.enumerated()
                                ),
                                id: \.offset
                            ) { index, _ in
                                DoublePageView(
                                    imageUrl: UserDefaults.standard.bool(forKey: "dataSaver") ? model.atHomeComponents[dataSaverIndex: index] : model.atHomeComponents[dataIndex: index],
                                    width: $model.pageWidths[index],
                                    height: $model.pageHeights[index]
                                )
                                .scaleEffect(x: -1)
                                .frame(
                                    width: model.pageWidths[index] > model.pageHeights[index] ? proxy.size.width : proxy.size.width/2,
                                    height: proxy.size.height, alignment: .center
                                )
                                .padding()
                                .containerRelativeFrame(
                                    .horizontal,
                                    count: model.pageWidths[index] > model.pageHeights[index] ? 1 : 2, spacing: 0
                                )
                            }
                        } else {
                            ForEach(
                                Array(UserDefaults.standard.bool(forKey: "dataSaver") ? model.atHomeComponents.dataSaver.enumerated() : model.atHomeComponents.data.enumerated()),
                                id: \.offset
                            ) { index, _ in
                                PageView(imageUrl: UserDefaults.standard.bool(forKey: "dataSaver") ? model.atHomeComponents[dataSaverIndex: index] : model.atHomeComponents[dataIndex: index])
                                    .scaleEffect(x: -1)
                                    .frame(
                                        width: proxy.size.width,
                                        alignment: .center
                                    )
                                    .frame(
                                        width: proxy.size.width,
                                        height: proxy.size.height
                                    )
                                    .safeAreaPadding(0)
                                    .containerRelativeFrame(
                                        .horizontal,
                                        count: 1,
                                        spacing: 0
                                    )
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.never)
                .flipsForRightToLeftLayoutDirection(true)
                .environment(\.layoutDirection, .rightToLeft)
            }
            .task { try? await model.fetchChapter() }
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

#if DEBUG
extension Bundle {
    func decode(from file: String) -> Chapter {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(Wrapper<Chapter>.self, from: data).data
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ReaderView(chapter: Bundle.main.decode(from: "Laid Back Camp Ch. 1 - Mt. Fuji and Cup Ramen.json"), title: "Ch. 1 - Mt. Fuji and Cup Ramen")
}
#endif
