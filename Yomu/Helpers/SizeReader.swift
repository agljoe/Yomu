//
//  SizeReader.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-07-03.
//

import SwiftUI

/// Reads the size of a view.
struct SizeReader: ViewModifier {
    /// The size of the view being read.
    @Binding var size: CGSize
    
    /// Returns the modified view with a binding vairable containing its size.
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { proxy in
                Color.clear
                    .onAppear{
                        size = proxy.size
                    }
            })
    }
}

extension View {
    /// Reads the size of the view this modifier is placed on.
    ///
    /// - Parameter size: a binding variable that is updated to the size of the view being read.
    ///
    /// - Returns: The the view this modifier was placed on, with its size.
    func readSize(size: Binding<CGSize>) -> some View {
        modifier(SizeReader(size: size))
    }
}
