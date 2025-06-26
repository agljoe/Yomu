//
//  CachedAsyncImage.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-13.
//

import Foundation
import SwiftUI

/// An asynchronously loaded image stored in a cache.
@MainActor
struct CachedAsyncImage<ImageView: View, PlaceholderView: View>: View {
    /// The URL of an image.
    var url: URL?
    
    /// A function that creates a view with a given image.
    @ViewBuilder var content: (Image) -> ImageView
    
    /// A function that returns any view.
    @ViewBuilder var placeholder: () -> PlaceholderView
    
    /// A UIImage initalized from the data requested found at `url`.
    @State var image: UIImage? = nil
    
    /// Creates a new `CachedAsyncImage` with the given values.
    ///
    /// - Parameters:
    ///  - url: the URL of the server where the image to be presented is hosted.
    ///  - content: a closure that creates a view with a given image.
    ///  - placeholder: a closure that creates a view.
    ///
    /// - Returns: a newly created `CachedAsyncImage` initialized by the given values.
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> ImageView, @ViewBuilder placeholder: @escaping () -> PlaceholderView) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    /// Presents an image,  or a place holder if the image is being loaded.
    var body: some View {
        VStack {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .task {
                        image = await downloadPhoto()
                    }
            }
        }
    }
    
    /// Downloads an image from this views `url`, or returns it from the cache if it has already been downloaded.
    ///
    /// - Returns: the requested image.
    private func downloadPhoto() async -> UIImage? {
        do {
            guard let url else { return nil }
            
            if let cachedResponse = URLCache.shared.cachedResponse(for: .init(url: url)) {
                return UIImage(data: cachedResponse.data)
            } else {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: .init(url: url))
                
                guard let image = UIImage(data: data) else { return nil }
                
                return image
            }
        } catch {
            print("Error downloading: \(error)")
            return nil
        }
    }
}
