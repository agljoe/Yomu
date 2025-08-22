//
//  Twist.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-08-14.
//

import SwiftUI

/// Applies a metal shader that twists a view with some irrequlartiy.
struct Warp: ViewModifier {
    /// The addition space that the applied shader can draw on.
    let maxSampleOffset: CGFloat
    
    /// The point around which cooridnates are distorted.
    let offset: CGSize
    
    /// Returns the given content with the warp shader applied.
    ///
    /// - Parameter content: a view.
    ///
    /// - Returns: the modified view.
    func body(content: Content) -> some View {
        content
            .padding(maxSampleOffset)
            .drawingGroup()
            .visualEffect { content, proxy in
                content
                    .distortionEffect(
                        ShaderLibrary.warp(
                            .float2(proxy.size),
                            .float2(offset),
                        ),
                        maxSampleOffset: .init(width: maxSampleOffset, height: maxSampleOffset)
                    )
            }
            .ignoresSafeArea(edges: .all)
        
    }
}

extension View {
    /// Twists a view using a metal shader.
    ///
    /// - Parameters:
    ///  - maxSampleOffset: an amount of additional space around the view the shader can draw on.
    ///  - offset: a point around which coordinates are distorted.
    ///
    ///  - Returns: a "twisted" view.
    func warp(
        maxSampleOffset: CGFloat = 250,
        offset: CGSize = .zero
    ) -> some View {
        modifier(Warp(maxSampleOffset: maxSampleOffset, offset: offset))
    }
}


