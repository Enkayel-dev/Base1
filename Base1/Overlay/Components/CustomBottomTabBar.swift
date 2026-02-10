//
//  CustomBottomTabBar.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct CustomBottomTabBar: View {
    @Environment(TabRouter.self) private var router
    @Environment(SearchState.self) private var searchState
    @Namespace private var glassNS
    
    private let tabs: [TabItem] = [
        TabItem(index: 0, label: "Clients", icon: "house.fill"),
        TabItem(index: 1, label: "Schedule", icon: "square.grid.2x2.fill"),
        TabItem(index: 2, label: "Projects", icon: "play.square.stack.fill"),
        TabItem(index: 3, label: "Resources", icon: "play.square.stack.fill"),
        TabItem(index: 4, label: "Finances", icon: "play.square.stack.fill"),
    ]
    
    var body: some View {
        HStack(spacing: DesignConstants.TabBar.spacing) {
            ForEach(tabs) { tab in
                tabButton(for: tab)
            }
            
            Spacer()
            
            searchToggleButton
        }
        .padding(.horizontal, 8)  // Reduced from 12
        .padding(.vertical, 8)
    }
    
    // MARK: - Tab Button
    
    @ViewBuilder
    private func tabButton(for tab: TabItem) -> some View {
        let isSelected = router.selectedTab == tab.index
        
        Button {
            router.select(tab.index)
            searchState.dismiss()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: tab.icon)
                    .font(.body)
                if isSelected {
                    Text(tab.label)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .frame(height: DesignConstants.TabBar.itemHeight)
            .padding(.horizontal, isSelected
                     ? DesignConstants.TabBar.activePaddingH
                     : DesignConstants.TabBar.inactivePaddingH)
            .background {
                if isSelected {
                    Capsule().fill(.blue.gradient)
                }
            }
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .glassEffectID(tab.label.lowercased(), in: glassNS)
    }
    
    // MARK: - Search Toggle
    
    private var searchToggleButton: some View {
        Button {
            searchState.toggle()
        } label: {
            Image(systemName: searchState.isActive ? "xmark" : "magnifyingglass")
                .font(.body)
                .foregroundStyle(.primary)
                .frame(
                    width: DesignConstants.TabBar.itemHeight,
                    height: DesignConstants.TabBar.itemHeight
                )
        }
        .glassEffect(.regular.interactive(), in: .circle)
        .glassEffectID("search", in: glassNS)
    }
}

// MARK: - Tab Item Model

private struct TabItem: Identifiable {
    let index: Int
    let label: String
    let icon: String
    var id: Int { index }
}
