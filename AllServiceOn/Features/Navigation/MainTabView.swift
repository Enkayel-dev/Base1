
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
        @Environment(DrawerRouter.self) private var drawerRouter
        @Environment(SearchState.self) private var searchState
        @Environment(WorkflowService.self) private var workflowService
        @Environment(\.modelContext) private var modelContext

        let backgroundService: BackgroundService

    var body: some View {
        ZStack(alignment: .bottom) {

            AnimatedMeshBackground()

            TabContentView()

            // MARK: - Drawer Overlay

            if drawerRouter.isPresented {
                SideDrawer(onDismiss: {
                    drawerRouter.dismiss()
                }) {
                    if let destination = drawerRouter.currentDrawer {
                        DrawerViewFactory(destination: destination)
                    }
                }
                .transition(.move(edge: .trailing))
                .zIndex(100)
            }

            if !tabRouter.isSettingsActive {
                BusinessLogo(isActive: tabRouter.isBusinessProfileActive) {
                    withAnimation(.spring(response: DesignConstants.Animation.quickResponse)) {
                        tabRouter.isBusinessProfileActive.toggle()
                    }
                }
            }

            if !tabRouter.isBusinessProfileActive {
                SettingsButton(isActive: tabRouter.isSettingsActive) {
                    withAnimation(.spring(response: DesignConstants.Animation.quickResponse)) {
                        tabRouter.isSettingsActive.toggle()
                    }
                }
            }

        }
        .animation(.spring(
            response: DesignConstants.Animation.morphResponse,
            dampingFraction: DesignConstants.Animation.morphDamping
        ), value: drawerRouter.isPresented)
        .onChange(of: tabRouter.selectedTab) { oldIndex, newIndex in
            if !tabRouter.isSettingsActive && !tabRouter.isBusinessProfileActive {
                let direction: TransitionDirection = newIndex > oldIndex ? .right : .left
                backgroundState.transition(
                    to: backgroundService.preferredScheme(for: newIndex),
                    direction: direction
                )
            }
        }
        .onChange(of: tabRouter.isSettingsActive) { _, isActive in
            if isActive {
                backgroundState.transition(to: .violet, direction: .left)
            } else if !tabRouter.isBusinessProfileActive {
                backgroundState.transition(
                    to: backgroundService.preferredScheme(for: tabRouter.selectedTab),
                    direction: .right
                )
            }
        }
        .onChange(of: tabRouter.isBusinessProfileActive) { _, isActive in
            if isActive {
                backgroundState.transition(to: .teal, direction: .right)
            } else if !tabRouter.isSettingsActive {
                backgroundState.transition(
                    to: backgroundService.preferredScheme(for: tabRouter.selectedTab),
                    direction: .left
                )
            }
        }
                    .onAppear {
                        workflowService.setContext(modelContext)

                        // Start a test workflow from template for development
                        let template = WorkflowTemplate.sampleNewLeadTemplate(businessKey: "BUS_DEV00001")
                        modelContext.insert(template)
                        workflowService.startWorkflow(from: template)

                        // Set initial scheme without animation
                        backgroundState.setScheme(backgroundService.preferredScheme(for: tabRouter.selectedTab))
                    }
                }
    // MARK: - Tab Content

    /// Manages the tab page switching and bottom bar inset.
    private struct TabContentView: View {
            @Environment(TabRouter.self) private var tabRouter

            var body: some View {
                GeometryReader { geometry in
                    ZStack {
                        BusinessProfile()
                            .offset(x: tabRouter.businessProfileOffset(screenWidth: geometry.size.width))
                            .zIndex(tabRouter.isBusinessProfileActive ? 2 : 0)

                        // Tab 1
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

                        SettingsView()
                            .offset(x: tabRouter.settingsOffset(screenWidth: geometry.size.width))
                            .zIndex(tabRouter.isSettingsActive ? 2 : 0)
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
            .environment(DrawerRouter())
            .environment(SearchState())
            .environment(WorkflowService())
            .preferredColorScheme(.dark)
    }
