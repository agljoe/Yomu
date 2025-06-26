//
//  YomuTests.swift
//  YomuTests
//
//  Created by Andrew Joe on 2024-09-30.
//

import Foundation
import Testing
@testable import Yomu

private extension Bundle {
    /// Same debug bundle decoding used to test custom decoding implemenations.
    ///
    /// This function will cause a fatal error, if the specficied file cannot be found, or
    /// is unable to decode the bundled data.
    ///
    /// - Parameter file: The name of the file to decode in the bundle.
    ///
    /// - Returns: The decoded data.
    ///
    /// - Throws: A decoding error if the requested file cannot be decoded.
    func testDecoding<T: Decodable>(from file: String) throws -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else { fatalError("Failed to locate \(file) in bundle.") }
        guard let data = try? Data(contentsOf: url) else { fatalError("Failed to load \(file) from bundle.") }
        
        let decoder = JSONDecoder()

        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone.current
        
        decoder.dateDecodingStrategy = .formatted(RFC3339DateFormatter)
        
        return try decoder.decode(T.self, from: data)
      
    }
}

struct YomuTests {
 
}


