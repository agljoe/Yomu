//
//  Request.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-07.
//

import Foundation

enum MDApiError: Error {
    case unknownResponse
    case badRequest
    case unauthorizedRequest
    case forbiddenRequest
    case notFound
    case serviceUnavailable
}

public class Request {
    public func post(url: URL, value: String, content: Data) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(value, forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = true
        
        request.httpMethod = "POST"
        
        request.httpBody = content
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            switch (response as? HTTPURLResponse)?.statusCode {
            case 400: 
                throw MDApiError.badRequest
            case 401:
                throw MDApiError.unauthorizedRequest
            case 403:
                throw MDApiError.forbiddenRequest
            case 404:
                throw MDApiError.notFound
            case 503:
                throw MDApiError.serviceUnavailable
            default:
                throw MDApiError.unknownResponse
            }
        }
        return data
    }
}

