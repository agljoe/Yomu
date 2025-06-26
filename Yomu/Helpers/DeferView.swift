//
//  DeferView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-14.
//

import Foundation
import SwiftUI

/// A wrapper that defers the fime of view creation to when it's first displayed.
struct DeferView<Content: View>: View {
    /// The view to be created.
    let content: () -> Content

    /// Creates a new view for the given closure.
    ///
    /// - Parameter content: the view to display.
    ///
    /// - Returns: a newly created  `DeferView` containing the specified view.
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    
    /// Presents `content`.
    var body: some View {
        /// Creates the given view.
        content()
    }
}
