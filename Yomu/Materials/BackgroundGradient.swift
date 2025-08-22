//
//  BackgroundGradient.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-08-15.
//

import SwiftUI

struct BackgroundGradient: View {
    let imageURL: URL
    
    var body: some View {
        LayeredImage(imageURL)
            .blur(radius: 125)
            .brightness(-0.2)
    }
    
    @ViewBuilder
    func LayeredImage(_ imageURL: URL) -> some View {
        ZStack {
            BottomLayer(imageURL)
            ImageLayer(imageURL, leading: true)
                .fixedSize()
            ImageLayer(imageURL, leading: false)
                .fixedSize()
        }
    }
    
    @ViewBuilder
    func BottomLayer(_ imageURL: URL) -> some View {
        CachedAsyncImage(url: imageURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Color.gray
        }
        .frame(width: 1000)
        .warp(offset: .init(
            width: 700,
            height: 0
        ))
        .offset(y: 200)
        
    }
    
    @ViewBuilder
    func ImageLayer(_ imageURL: URL, leading: Bool) -> some View {
        CachedAsyncImage(url: imageURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Color.gray
        }
        .frame(width: 700)
        .rotationEffect(Angle(degrees: 45))
        .warp(offset:.init(
            width: leading ? 1000 : 100,
            height: leading ? 500 : 500
        ))
        .offset(
            x: leading ? -100 : 500,
            y: leading ? 100 : -200
        )
    }
}

#Preview {
    BackgroundGradient(imageURL: URL(string: "https://uploads.mangadex.org/covers/1ee97895-4796-4bcf-bcd1-5ef99c011f8b/52cd5815-c856-44cb-8ae2-1f1c4d1398ed.jpg.256.jpg")!)
}
