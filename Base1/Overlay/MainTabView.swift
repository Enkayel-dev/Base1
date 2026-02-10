//
//  MainTabView 2.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//


//
//  MainTabView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct MainTabView: View {
    @State private var router = TabRouter()
    @State private var searchState = SearchState()
    @State private var workflowManager = WorkflowManager()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            
            AnimatedMeshBackground()
            
            TabContentView()
           
            BusinessLogo()
           
            SettingsButton()
    
            
        }
        
        .environment(router)
        .environment(searchState)
        .environment(workflowManager)
        .onAppear {
            // Load placeholder workflow for demo
            workflowManager.loadPlaceholder()
        }
    }
}

// MARK: - Tab Content

/// Manages the tab page switching and bottom bar inset.
private struct TabContentView: View {
    @Environment(TabRouter.self) private var router
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Tab1View()
                    .offset(x: router.offsetForTab(0, screenWidth: geometry.size.width))
                    .zIndex(router.selectedTab == 0 ? 1 : 0)
                
                Tab2View()
                    .offset(x: router.offsetForTab(1, screenWidth: geometry.size.width))
                    .zIndex(router.selectedTab == 1 ? 1 : 0)
                
                Tab3View()
                    .offset(x: router.offsetForTab(2, screenWidth: geometry.size.width))
                    .zIndex(router.selectedTab == 2 ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(
                .spring(
                    response: DesignConstants.Animation.tabSwitchResponse,
                    dampingFraction: DesignConstants.Animation.tabSwitchDamping
                ),
                value: router.selectedTab
            )
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomBarView()
            }
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}
