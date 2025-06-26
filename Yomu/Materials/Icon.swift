//
//  Icon.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-13.
//

import SwiftUI

/// An shape that resembles an Apple style app icon.
struct Icon: View {
    /// The system name of an SFSymbol.
    var symbol: String
    
    /// The desired size of the specified SFSymbol.
    var symbolSize: Image.Scale
    
    /// The foreground colour of the displayed SFSymbol.
    var symbolColor: Color
    
    /// The colour of the icon box.
    var iconColor: Color
    
    /// Returns a coloured icon with an SFSymbol placed in its center.
    var body: some View {
        Image(systemName: symbol)
            .imageScale(symbolSize)
            .frame(width: 30, height: 30)
            .foregroundStyle(symbolColor)
            .background(iconColor)
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

#Preview {
    Icon(symbol: "gear", symbolSize: .large, symbolColor: .white, iconColor: .gray)
}
