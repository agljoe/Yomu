//
//  ImageLoader.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-01-23.
//

import Foundation
import SwiftUI

///
actor ImageLoader {
    public func fetch(_ urlRequest: URLRequest) async throws -> UIImage {
        let task: Task<UIImage, Error> = Task {
            let startDate = Date.now
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            let comletionTime = Date().timeIntervalSince(startDate)
            await atHomeReport(url: urlRequest.url!.absoluteString, response: response, duration: Int((comletionTime*1000).truncatingRemainder(dividingBy: 1000)))
            let image = UIImage(data: data)!
            
            return image
        }
        
        let image = try await task.value
    
        return image
    }

    private enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
}

struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue = ImageLoader()
}

extension EnvironmentValues {
    var imageLoader: ImageLoader {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self ] = newValue}
    }
}

struct RemoteImage: View {
    private let source: URLRequest
    @State private var image: UIImage?

    @Environment(\.imageLoader) private var imageLoader

    init(source: URL) {
        self.init(source: URLRequest(url: source))
    }

    init(source: URLRequest) {
        self.source = source
    }

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

    func loadImage(at source: URLRequest) async {
        do {
            image = try await imageLoader.fetch(source)
        } catch {
            print(error)
        }
    }
}
