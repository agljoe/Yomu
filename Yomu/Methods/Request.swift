//
//  Request.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-07.
//

import Foundation

enum MDApiError: Error {
    case invalidResponse
    case badRequest
    case forbiddenRequest
    case notFound
    case unauthorizedRequest
    case serviceUnavailable
}

public class Request {
    public func post<T: Encodable>(url: URL, value: String, content: T) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(value, forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = true
        
        request.httpMethod = "POST"
        
        request.httpBody = content as? Data
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw MDApiError.badRequest } // fix to handle specific errors
        return data
        
    }
}

