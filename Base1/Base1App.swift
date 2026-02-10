import SwiftUI
import SwiftData
import Observation

@main
struct Base1App: App {

    // MARK: - Shared Observable State
    @State private var backgroundState = BackgroundState()
    @State private var tabRouter = TabRouter()
    @State private var searchState = SearchState()
    @State private var workflowService = WorkflowService()
    @State private var businessManager: BusinessManager   // ← use manager directly

    private let backgroundService = BackgroundService()

    let modelContainer: ModelContainer

    init() {
        // MARK: - ModelContainer setup
        let schema = Schema(Base1SchemaV1.models)
        let config = ModelConfiguration()

        do {
            modelContainer = try ModelContainer(
                for: schema,
                migrationPlan: Base1MigrationPlan.self,
                configurations: [config]
            )
        } catch {
            print("ModelContainer failed: \(error). Deleting store and retrying.")
            let storeURL = config.url
            let related = [storeURL, storeURL.appendingPathExtension("wal"), storeURL.appendingPathExtension("shm")]
            for url in related { try? FileManager.default.removeItem(at: url) }
            modelContainer = try! ModelContainer(
                for: schema,
                migrationPlan: Base1MigrationPlan.self,
                configurations: [config]
            )
        }

        // MARK: - Initialize BusinessManager AFTER ModelContainer
        businessManager = BusinessManager(container: modelContainer)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(backgroundService: backgroundService)
                .environment(backgroundState)
                .environment(tabRouter)
                .environment(searchState)
                .environment(workflowService)
                .environment(businessManager)   // ← inject manager instead of context
        }
        .modelContainer(modelContainer)
    }
}
