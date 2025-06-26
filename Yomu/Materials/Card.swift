//
//  Card.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-22.
//

import SwiftUI


struct Card: ViewModifier {
    func body(content: Content) -> some View  {
        content
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(Card())
    }
}

