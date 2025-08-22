//
//  CustomTabBar.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-08-15.
//

import SwiftUI

enum TabModel: String, CaseIterable {
    case volumes = "Volumes"
    case chapters = "Chapters"
}

struct CustomTabBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var activeTab: TabModel
    
    var body: some View {
        GeometryReader { _ in
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(TabModel.allCases, id: \.rawValue) { tab in
                        ResizeableTabButton(tab)
                    }
                }
                .background {
                    GeometryReader { proxy in
                        Rectangle()
                            .fill(Color.primary)
                            .frame(width: proxy.size.width / 2, alignment: .leading)
                            .clipShape(Capsule(style: .continuous))
                            .offset(x: activeTab == .volumes ? -2.5 : proxy.size.width / 2)
                    }
                }
                .contentShape(.rect)
            }
        }
        .frame(height: 50)
    }
    
    @ViewBuilder
    func ResizeableTabButton(_ tab: TabModel) -> some View {
        HStack(spacing: 8) {
            Text(tab.rawValue)
                .font(.system(size: 18))
                .fontWeight(.semibold)
        }
        .foregroundStyle(activeTab == tab ? colorScheme == .dark ? .black : .white : .primary)
        .frame(height: 40)
        .padding(.horizontal, 10)
        .onTapGesture {
            withAnimation(.spring(duration: 0.35)) {
                activeTab = tab
            }
        }
    }
}

#if DEBUG
private struct CustomTabPreview: View {
    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false
    @State private var activeTab: TabModel = .volumes
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    CustomTabBar(activeTab: $activeTab)
                        .padding(.horizontal, 20)
                }
            }
            .navigationTitle(Text("Library"))
            .searchable(text: $searchText, isPresented: $isSearchActive, placement: .navigationBarDrawer(displayMode: .automatic))
            .background(.gray.opacity(0.08))
        }
    }
}

#Preview {
    CustomTabPreview()
}
#endif
