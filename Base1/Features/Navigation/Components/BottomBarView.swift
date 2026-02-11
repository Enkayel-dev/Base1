//
//  BottomBarView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct BottomBarView: View {
    @Environment(SearchState.self) private var searchState
    
    var body: some View {
        GlassEffectContainer(spacing: 8) {
            VStack(spacing: 0) {
                // Contextual top section: search or active workflow
                if searchState.isActive {
                    SearchBar()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    WorkflowMiniCard()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Tab bar
                CustomBottomTabBar()
            }
            .padding(.horizontal, DesignConstants.BottomBar.innerHorizontalPadding)
            .padding(.vertical, DesignConstants.BottomBar.innerVerticalPadding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.BottomBar.cornerRadius))
        }
        .padding(.horizontal, DesignConstants.BottomBar.horizontalPadding)
        .padding(.bottom, DesignConstants.BottomBar.bottomPadding)
    }
}
