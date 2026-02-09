//
//  MainTabView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct MainTabView: View {
    @State private var searchText = ""
    @State private var isPlaying = false
    @State private var selectedTab = 0
    @State private var isSearchActive = false
    @Namespace private var namespace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Global animated mesh gradient background
            AnimatedMeshBackground()
            
            // Main content area with slide transitions
            GeometryReader { geometry in
                ZStack {
                    Tab1View()
                        .offset(x: offsetForTab(0, screenWidth: geometry.size.width))
                        .zIndex(selectedTab == 0 ? 1 : 0)
                    
                    Tab2View()
                        .offset(x: offsetForTab(1, screenWidth: geometry.size.width))
                        .zIndex(selectedTab == 1 ? 1 : 0)
                    
                    Tab3View()
                        .offset(x: offsetForTab(2, screenWidth: geometry.size.width))
                        .zIndex(selectedTab == 2 ? 1 : 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    // Single unified container for seamless glass effect
                    GlassEffectContainer(spacing: 8) {
                        VStack(spacing: 0) {
                            // Mini player or Search Bar (with morphing transition)
                            if isSearchActive {
                                SearchBarContent(searchText: $searchText, isActive: $isSearchActive)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            } else {
                                NowPlayingMiniPlayerContent(isPlaying: $isPlaying)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                            
                            // Custom Tab Bar with Search Button
                            CustomBottomTabBarContent(
                                selectedTab: $selectedTab,
                                isSearchActive: $isSearchActive
                            )
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 48))
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func offsetForTab(_ tab: Int, screenWidth: CGFloat) -> CGFloat {
        if selectedTab == tab {
            return 0 // Current tab is centered
        } else if selectedTab > tab {
            return -screenWidth // Previous tabs slide left
        } else {
            return screenWidth // Next tabs slide right
        }
    }
}

struct CustomBottomTabBarContent: View {
    @Binding var selectedTab: Int
    @Binding var isSearchActive: Bool
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 8) {
            // Home Tab
            Button {
                withAnimation(.spring(response: 0.3)) {
                    selectedTab = 0
                    isSearchActive = false
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "house.fill")
                        .font(.body)
                    if selectedTab == 0 {
                        Text("Home")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(selectedTab == 0 ? .white : .primary)
                .frame(height: 36)
                .padding(.horizontal, selectedTab == 0 ? 16 : 12)
                .background {
                    if selectedTab == 0 {
                        Capsule()
                            .fill(.blue.gradient)
                    }
                }
            }
            .glassEffect(.regular.interactive(), in: .capsule)
            .glassEffectID("home", in: namespace)
            
            // Browse Tab
            Button {
                withAnimation(.spring(response: 0.3)) {
                    selectedTab = 1
                    isSearchActive = false
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.body)
                    if selectedTab == 1 {
                        Text("Browse")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(selectedTab == 1 ? .white : .primary)
                .frame(height: 36)
                .padding(.horizontal, selectedTab == 1 ? 16 : 12)
                .background {
                    if selectedTab == 1 {
                        Capsule()
                            .fill(.blue.gradient)
                    }
                }
            }
            .glassEffect(.regular.interactive(), in: .capsule)
            .glassEffectID("browse", in: namespace)
            
            // Library Tab
            Button {
                withAnimation(.spring(response: 0.3)) {
                    selectedTab = 2
                    isSearchActive = false
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "play.square.stack.fill")
                        .font(.body)
                    if selectedTab == 2 {
                        Text("Library")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(selectedTab == 2 ? .white : .primary)
                .frame(height: 36)
                .padding(.horizontal, selectedTab == 2 ? 16 : 12)
                .background {
                    if selectedTab == 2 {
                        Capsule()
                            .fill(.blue.gradient)
                    }
                }
            }
            .glassEffect(.regular.interactive(), in: .capsule)
            .glassEffectID("library", in: namespace)
            
            Spacer()
            
            // Search Button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isSearchActive.toggle()
                }
            } label: {
                Image(systemName: isSearchActive ? "xmark" : "magnifyingglass")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
            }
            .glassEffect(.regular.interactive(), in: .circle)
            .glassEffectID("search", in: namespace)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct SearchBarContent: View {
    @Binding var searchText: String
    @Binding var isActive: Bool
    @FocusState private var isFocused: Bool
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.body)
            
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .submitLabel(.search)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
                .glassEffect(.regular.interactive(), in: .circle)
                .glassEffectID("clear", in: namespace)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onAppear {
            isFocused = true
        }
    }
}

struct NowPlayingMiniPlayerContent: View {
    @Binding var isPlaying: Bool
    @State private var progress: Double = 0.3
    @Namespace private var namespace
    
    var body: some View {
        VStack(spacing: 8) {
            // Main player controls
            HStack(spacing: 12) {
                // Album artwork
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.gradient)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundStyle(.white)
                    }
                    .glassEffect(.regular, in: .rect(cornerRadius: 8))
                    .glassEffectID("artwork", in: namespace)
                
                // Track info
                VStack(alignment: .leading, spacing: 2) {
                    Text("Song Title")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Artist Name")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isPlaying.toggle()
                        }
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .frame(width: 44, height: 44)
                    }
                    .glassEffect(.regular.interactive(), in: .circle)
                    .glassEffectID("play", in: namespace)
                    
                    Button {
                        // Next track
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title3)
                            .frame(width: 44, height: 44)
                    }
                    .glassEffect(.regular.interactive(), in: .circle)
                    .glassEffectID("forward", in: namespace)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Progress timeline with Liquid Glass - now at the bottom
            GeometryReader { geometry in
                let trackWidth = geometry.size.width
                
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(.quaternary)
                        .frame(height: 3)
                    
                    // Progress track with glass effect
                    Capsule()
                        .fill(.white)
                        .frame(width: trackWidth * progress, height: 3)
                        .glassEffect(.regular, in: .capsule)
                        .glassEffectID("progress", in: namespace)
                    
                    // Draggable handle with Liquid Glass
                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .glassEffect(.regular.interactive(), in: .circle)
                        .glassEffectID("handle", in: namespace)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .offset(x: (trackWidth * progress) - 8) // Center the circle on the progress
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // Use the actual geometry width from context
                            progress = min(max(0, value.location.x / trackWidth), 1.0)
                        }
                )
            }
            .frame(height: 20) // Increased height to accommodate the handle
            .padding(.horizontal, 4)
        }
        .onAppear {
            // Simulate playback progress
            if isPlaying {
                startProgressAnimation()
            }
        }
        .onChange(of: isPlaying) { _, newValue in
            if newValue {
                startProgressAnimation()
            }
        }
    }
    
    private func startProgressAnimation() {
        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
            if progress < 1.0 {
                progress = 1.0
            }
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}
