//
//  ContentView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    // Create local state for preview/standalone usage
    @State private var backgroundState = BackgroundState()
    @State private var tabRouter = TabRouter()
    @State private var searchState = SearchState()
    @State private var workflowService = WorkflowService()
    
    private let backgroundService = BackgroundService()
    
    var body: some View {
        MainTabView(backgroundService: backgroundService)
            .environment(backgroundState)
            .environment(tabRouter)
            .environment(searchState)
            .environment(workflowService)
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleDataContainer.preview)
}

