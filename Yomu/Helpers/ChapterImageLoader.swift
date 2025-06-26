//
//  ChapterImageLoader.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-23.
//

import Foundation
import SwiftUI

/// An isolated image downloader.
actor ImageLoader {
    /// Downloads an image by requesting with the given request.
    ///
    /// - Parameter urlRequest: a request to the server that hosts the desired image.
    ///
    /// - Returns: a `UIImage` initialized from the retrieved data.
    ///
    /// - Throws: an error if the image download request fails.
    public func fetch(_ urlRequest: URLRequest) async throws -> UIImage {
        let task: Task<UIImage, Error> = Task {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let image = UIImage(data: data)!
            return image
        }
        
        let image = try await task.value
        return image
    }

    /// The status of this image loader.
    private enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
}

extension EnvironmentValues {
    /// Lets an image loader be used as an environment value.
    @Entry var imageLoader: ImageLoader = ImageLoader()
}

/// A single "page" of a chapter.
///
/// - Note: For simplicity double width art pages are consider one page, despite using two pages
///         worth of indexes.
struct ChapterPageImage: View {
    /// A request that can be used to get an image.
    private let source: URLRequest
    
    /// The image presented by this view.
    @State private var image: UIImage?

    /// The image loader for this view.
    @Environment(\.imageLoader) private var imageLoader

    /// Creates a new  `ChapterPageImage` with the given URL.
    ///
    /// - Parameter source: the server where the specified image is hosted.
    ///
    /// - Returns: a newly created `ChapterPageImage` for the image at the specified URL.
    init(source: URL) {
        self.init(source: URLRequest(url: source))
    }

    
    /// Creates a new  `ChapterPageImage` with the given URL request.
    ///
    /// - Parameter source: a request for the image to be presented.
    ///
    /// - Returns: a newly created `ChapterPageImage` for the image from the specified request.
    init(source: URLRequest) {
        self.source = source
    }

    /// Presents an image asynchronously.
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image).resizable()
            } else {
                ProgressView()
            }
        }
        .task {
            await loadImage(at: source)
        }
    }

    /// Loads the image with the given request.
    ///
    /// - Parameter source: a request for the image to be presented.
    func loadImage(at source: URLRequest) async {
        do {
            image = try await imageLoader.fetch(source)
        } catch {
            print(error)
        }
    }
}
