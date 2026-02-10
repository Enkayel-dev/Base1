
//
//  MainTabView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
        @Environment(BackgroundState.self) private var backgroundState
        @Environment(TabRouter.self) private var tabRouter
        @Environment(SearchState.self) private var searchState
        @Environment(WorkflowService.self) private var workflowService
        @Environment(\.modelContext) private var modelContext
        
        let backgroundService: BackgroundService
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            AnimatedMeshBackground(scheme: backgroundState.scheme)
            
            TabContentView()
            
            BusinessLogo()
            
            SettingsButton()

                    }
            .onChange(of: tabRouter.selectedTab) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.6)) {
                    backgroundState.scheme = backgroundService.preferredScheme(for: newIndex)
                }
            }
                    .onAppear {
                        workflowService.setContext(modelContext)
                        
                        // Start placeholder workflow for testing
                        workflowService.startWorkflow(.testWorkflow)
                        
                        withAnimation(.easeInOut(duration: 0.6)) {
                            backgroundState.scheme = backgroundService.preferredScheme(for: tabRouter.selectedTab)
                        }
                    }
                }
    // MARK: - Tab Content
    
    /// Manages the tab page switching and bottom bar inset.
    private struct TabContentView: View {
            @Environment(TabRouter.self) private var tabRouter
            
            var body: some View {
                GeometryReader { geometry in
                    ZStack {
                        Tab1View()
                            .offset(x: tabRouter.offsetForTab(0, screenWidth: geometry.size.width))
                            .zIndex(tabRouter.selectedTab == 0 ? 1 : 0)
                        
                        Tab2View()
                            .offset(x: tabRouter.offsetForTab(1, screenWidth: geometry.size.width))
                            .zIndex(tabRouter.selectedTab == 1 ? 1 : 0)
                        
                        Tab3View()
                            .offset(x: tabRouter.offsetForTab(2, screenWidth: geometry.size.width))
                            .zIndex(tabRouter.selectedTab == 2 ? 1 : 0)
                        
                        Tab4View()
                            .offset(x: tabRouter.offsetForTab(3, screenWidth: geometry.size.width))
                            .zIndex(tabRouter.selectedTab == 3 ? 1 : 0)
                        
                        Tab5View()
                            .offset(x: tabRouter.offsetForTab(4, screenWidth: geometry.size.width))
                            .zIndex(tabRouter.selectedTab == 4 ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(
                        .spring(
                            response: DesignConstants.Animation.tabSwitchResponse,
                            dampingFraction: DesignConstants.Animation.tabSwitchDamping
                        ),
                        value: tabRouter.selectedTab
                    )
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        BottomBarView()
                    }
                }
            }
        }
    }

    #Preview {
        MainTabView(backgroundService: BackgroundService())
            .environment(BackgroundState())
            .environment(TabRouter())
            .environment(SearchState())
            .environment(WorkflowService())
            .preferredColorScheme(.dark)
    }
