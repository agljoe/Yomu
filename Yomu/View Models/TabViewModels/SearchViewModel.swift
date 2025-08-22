//
//  SearchViewModel.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-06-26.
//

import Foundation
import MangaDexData
import MangaDexAPIKit
import Observation

/// A class that handles all logic used to search for Manga.
@MainActor @Observable
class SearchViewModel {
    /// The manga that have been loaded.
    private(set) var manga: [Manga] = []
    
    /// Indicates if manga are currently being retirieved.
    private(set) var isLoading: Bool = false
    
    var fitlers = [URLQueryItem]()
    
    func fetch() async throws {
        
    }
}

