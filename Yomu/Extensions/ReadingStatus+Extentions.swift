//
//  ReadingStatus+Extentions.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-06-23.
//

import Foundation
import MangaDexAPIKit
import SwiftUI

extension ReadingStatus: @retroactive Identifiable {
    /// Conformance to allow instances of ReadingStatus to be used in a ForEach.
    ///
    /// - Important: This does not garuntee that every ReadingStatus variable is unique.
    public var id: Self { self }
}

public extension ReadingStatus {
    /// Returns a formatted string for each ReadinStatus case.
    var displayTitle: String {
        switch self {
        case .none:
            "None"
        case .reading:
            "Reading"
        case .on_hold:
            "On Hold"
        case .dropped:
            "Dropped"
        case .plan_to_read:
            "Plan to Read"
        case .completed:
            "Completed"
        case .re_reading:
            "Re-Reading"
        }
    }
    
    /// Returns the SFSymbol icon name associated with each ReadingStatus case.
    var systemImageName: String {
        switch self {
        case .none:
            "bookmark.slash.fill"
        case .reading:
            "book.fill"
        case .on_hold:
            "bookmark.fill"
        case .dropped:
            "archivebox.fill"
        case .plan_to_read:
            "books.vertical.fill"
        case .completed:
            "book.closed.fill"
        case .re_reading:
            "arrow.trianglehead.clockwise"
        }
    }
    
    /// Returns the color associated with each ReadingStatus case.
    var color: Color {
        switch self {
        case .none:
                .gray
        case .reading:
                .green
        case .on_hold:
                .orange
        case .dropped:
                .red
        case .plan_to_read:
                .purple
        case .completed:
                .cyan
        case .re_reading:
                .mint
        }
    }
}
