//
//  RequestExecutor.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-29.
//

import Foundation

protocol RequestExecutor: Sendable {
    func execute<T>(request: any MangaDexAPIRequest) async throws -> T
}

struct MangaDexAPIRequestExecutor: RequestExecutor {
    func execute<T>(request: any MangaDexAPIRequest) async throws -> T {
        guard let result = try await request.execute() as? T else { fatalError("Failed to create a \(T.self) from \(request)") }
        return result
    }
}
