//
//  MangaToolBarItem.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-07-10.
//

import SwiftUI

/// Applies the style of a small icon.
struct MangaToolBarItem: ViewModifier {
    /// The size length of the content being styled.
    ///
    /// The returned content will have a square frame.
    let size: CGFloat
    
    /// The color of this item.
    let background: Color
    
    /// Creates a square with rounded corners around the given content.
    ///
    /// - Parameter content: the view to be modified.
    ///
    /// - Returns: the modified content.
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    /// Applys the MangaToolBarItem ViewModifier to the selected view.
    func mangaToolBarItem(size: CGFloat, background: Color = Color(UIColor.systemBackground)) -> some View {
        modifier(MangaToolBarItem(size: size, background: background))
    }
}
