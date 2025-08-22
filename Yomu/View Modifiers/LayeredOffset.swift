//
//  LayeredOffset.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-08-16.
//

import SwiftUI

struct LayeredOffset: ViewModifier {
    let x: CGFloat
    let y: CGFloat
    
    init(position: Int) {
        switch position {
        case 1:
            self.x = 0
            self.y = 0
        case 2:
            self.x = -45
            self.y = 5
        case 3:
            self.x = 45
            self.y = 5
        case 4:
            self.x = -80
            self.y = 10
        case 5:
            self.x = 80
            self.y = 10
        default:
            self.x = 0
            self.y = 0
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: x, y: y)
    }
}

extension View {
    public func layeredOffset(position: Int) -> some View {
        modifier(LayeredOffset(position: position))
    }
}


