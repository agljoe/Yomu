//
//  ReaderView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-21.
//

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

/// Reads the size of a view.
struct SizeReader: ViewModifier {
    /// The size of the view being read.
    @Binding var size: CGSize
    
    /// Returns the modified view with a binding vairable containing its size.
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { proxy in
                Color.clear
                    .onAppear{
                        size = proxy.size
                    }
            })
    }
}

extension View {
    /// Reads the size of the view this modifier is placed on.
    ///
    /// - Parameter size: a binding variable that is updated to the size of the view being read.
    ///
    /// - Returns: The the view this modifier was placed on, with its size.
    func readSize(size: Binding<CGSize>) -> some View {
        modifier(SizeReader(size: size))
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

extension AtHomeChapterComponents {
    /// Returns the complete URL for downloading a chapter image.
    ///
    /// A page's number minus one is equivalent to its index in the 'data' array.
    ///
    /// - Parameter index: the index of a page.
    ///
    /// - Returns: a complete URL that can be used to download a chapter image.
    ///
    /// - Note: Image URLs are constructed using the structure '$.baseUrl / $QUALITY / $.chapter.hash / $.chapter.$QUALITY[*]'
    subscript(dataIndex index: Int) -> URL {
        return URL(string: "\(baseUrl)/data/\(hash)/\(data[index])")!
    }
    
    /// Returns the complete URL for downloading a lower quality chapter image.
    ///
    /// A page's number minus one is equivalent to its index in the 'dataSaver' array.
    ///
    /// - Parameter index: the index of a page.
    ///
    /// - Returns: a complete URL that can be used to download a chapter image.
    ///
    /// - Note: Image URLs are constructed using the structure '$.baseUrl / $QUALITY / $.chapter.hash / $.chapter.$QUALITY[*]'
    subscript(dataSaverIndex index: Int) -> URL {
        return URL(string: "\(baseUrl)/data-saver/\(hash)/\(dataSaver[index])")!
    }
}

// TODO: make custom view for page diplays


struct ReaderView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var orientation = UIDevice.current.orientation
    @State private var navBarVisisble: Bool = true
    @State var model: Model
    
    let title: String
    
    init(chapter: Chapter, title: String) {
        self.title = title
        self.model = Model(chapter: chapter)
        self._model = .init(initialValue: model)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack {
                        if orientation.isLandscape {
                            ForEach(Array(UserDefaults.standard.bool(forKey: "dataSaver") ? model.atHomeComponents.dataSaver.enumerated() : model.atHomeComponents.data.enumerated()), id: \.offset) { index, _ in
                                DoublePageView(imageUrl: UserDefaults.standard.bool(forKey: "dataSaver") ? model.atHomeComponents[dataSaverIndex: index] : model.atHomeComponents[dataIndex: index], width: $model.pageWidths[index], height: $model.pageHeights[index])
                                    .scaleEffect(x: -1)
                                    .frame(width: model.pageWidths[index] > model.pageHeights[index] ? proxy.size.width : proxy.size.width/2, height: proxy.size.height, alignment: .center)
                                    .padding()
                                    .containerRelativeFrame(.horizontal, count: model.pageWidths[index] > model.pageHeights[index] ? 1 : 2, spacing: 0)
                            }
                        } else {
                            ForEach(Array(UserDefaults.standard.bool(forKey: "dataSaver") ? model.atHomeComponents.dataSaver.enumerated() : model.atHomeComponents.data.enumerated()), id: \.offset) { index, _ in
                                PageView(imageUrl: UserDefaults.standard.bool(forKey: "dataSaver") ? model.atHomeComponents[dataSaverIndex: index] : model.atHomeComponents[dataIndex: index])
                                    .scaleEffect(x: -1)
                                    .frame(width: proxy.size.width, alignment: .center)
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .safeAreaPadding(0)
                                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
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
            .task { try? await model.fetch() }
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

extension ReaderView {
    @Observable
    class Model {
        private(set) var chapter: Chapter
        private(set) var atHomeComponents: AtHomeChapterComponents = AtHomeChapterComponents()
        private(set) var isLoading: Bool = false
        
        var pageWidths = [CGFloat]()
        var pageHeights = [CGFloat]()
        
        init(chapter: Chapter) {
            self.chapter = chapter
        }
        
        @MainActor
        func fetch() async throws {
            guard !self.isLoading else { return }
            defer { self.isLoading = false }
            self.isLoading = true
            
            let id = self.chapter.id
            
            async let compontents = AtHomeRequest(for: id).execute()
            self.pageWidths = Array(Array(repeating: CGFloat.zero, count: try await compontents.data.count))
            self.pageHeights = Array(Array(repeating: CGFloat.zero, count: try await compontents.data.count))
            self.atHomeComponents = try await compontents
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
#endif

#Preview {
    ReaderView(chapter: Bundle.main.decode(from: "Laid Back Camp Ch. 1 - Mt. Fuji and Cup Ramen.json"), title: "Ch. 1 - Mt. Fuji and Cup Ramen")
}
