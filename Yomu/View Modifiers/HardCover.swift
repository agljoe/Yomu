//
//  HardCover.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-07-03.
//

import SwiftUI

struct HardCover: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    private let coverSize: CGSize = .init(width: 512, height: 728)

    let scale: CGFloat
    var isShadowDrawn: Bool = false
    
    func body(content: Content) -> some View {
        Group {
            ZStack {
                if isShadowDrawn { drawShadow(colorScheme: colorScheme) }
                
                content
                    .frame(width: coverSize.width * scale, height: coverSize.height * scale)
                    .clipShape(RoundedRectangle(cornerRadius: 2.5))
                
//                Image("Cover Spine Linear Burn Blend")
//                    .resizable()
//                    .frame(width: coverSize.width * scale, height: coverSize.height * scale)
//                    .opacity(0.5)
                
                Image("Cover Soft Light Blend")
                    .resizable()
                    .frame(width: coverSize.width * scale, height: coverSize.height * scale)
                    .opacity(0.25)
                
                Image("Cover Flat Spine")
                    .resizable()
                    .frame(width: coverSize.width * scale, height: coverSize.height * scale)
                    .opacity(0.5)
                
                Image("Cover Flat Edges")
                    .resizable()
                    .frame(width: coverSize.width * scale, height: coverSize.height * scale)
            }
        }
    }
    
    
    @ViewBuilder
    func drawShadow(colorScheme: ColorScheme) -> some View {
        switch colorScheme {
        case .light:
            Image("Cover Flat Shadow")
                .resizable()
                .scaleEffect(x: 1.215, y: 1.17)
                .frame(width: coverSize.width * scale, height: coverSize.height * scale)
                .offset(y: coverSize.height * scale * (26 / 728))
        case .dark:
            Image("Cover Flat Shadow")
                .resizable()
                .scaleEffect(x: 1.215, y: 1.17)
                .frame(width: coverSize.width * scale, height: coverSize.height * scale)
                .offset(y: coverSize.height * scale * (26 / 728))
                .colorInvert()
                .opacity(0.5)
        @unknown default:
            Image("Cover Flat Shadow")
                .resizable()
                .scaleEffect(x: 1.215, y: 1.17)
                .frame(width: coverSize.width * scale, height: coverSize.height * scale)
                .offset(y: coverSize.height * scale * (26 / 728))
        }
    }
}

extension View {
    func hardCover(scale: CGFloat, isShadowDrawn: Bool = false) -> some View {
        modifier(HardCover(scale: scale, isShadowDrawn: isShadowDrawn))
    }
}

struct CoverView: View {
    let coverURL: URL
    let scale: CGFloat
    
    var body: some View {
        CachedAsyncImage(url: coverURL) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            Color.gray
        }
        .hardCover(scale: scale)
    }
}


private struct CoverPreview: View {
    let imageName: String = "Yuru Camp Vol 1 Sample Cover"
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
//            .opacity(0)
            .hardCover(scale: 1 / 2, isShadowDrawn: true)
            .padding()
    }
}


#Preview {
    CoverPreview()
}
