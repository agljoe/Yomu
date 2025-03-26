//
//  DeferView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-14.
//

import Foundation
import SwiftUI

struct DeferView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        content()          // << everything is created here
    }
}
