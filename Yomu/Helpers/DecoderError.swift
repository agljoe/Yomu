//
//  DecoderError.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-03.
//

import Foundation

/// 
public func handleDecodingError(_ error: DecodingError) {
    switch error {
    case let .typeMismatch(type, context):
        print("Type '\(type)' mismatch:", context.debugDescription)
        print("codingPath:", context.codingPath)
    case let .valueNotFound(value, context):
        print("Value '\(value)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)
    case let .keyNotFound(key, context):
        print("Key '\(key)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)
    case let .dataCorrupted(context):
        print(context)
    @unknown default:
        print("Failed to decode data: reason unknown")
    }
}
