//
//  Icon.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-13.
//

import SwiftUI

struct Icon: View {
    var symbol: String
    var symbolSize: Image.Scale
    var symbolColor: Color
    var iconColor: Color
    
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
