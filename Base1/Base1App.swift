import SwiftUI
import SwiftData

@main
struct Base1App: App {

    // MARK: - Shared Observable State
    @State private var backgroundState = BackgroundState()
    @State private var tabRouter = TabRouter()
    @State private var searchState = SearchState()
    @State private var workflowService = WorkflowService()
    
    private let backgroundService = BackgroundService()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(backgroundService: backgroundService)
                // Inject shared state into the environment
                .environment(backgroundState)
                .environment(tabRouter)
                .environment(searchState)
                .environment(workflowService)
        }
        .modelContainer(for: [Workflow.self, WorkflowStep.self])
    }
}
