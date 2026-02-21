import SwiftUI
import SwiftData
import Observation

@main
struct AllServiceOn: App {

    // MARK: - Shared Observable State
    @State private var backgroundState = BackgroundState()
    @State private var tabRouter = TabRouter()
    @State private var searchState = SearchState()
    @State private var workflowService = WorkflowService()
    @State private var drawerRouter = DrawerRouter()
    @State private var portalService = PortalService()
    @State private var authService = AuthService()
    @State private var subscriptionManager = SubscriptionManager()
    @State private var cloudKitSharingService = CloudKitSharingService()

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
    }

    var body: some Scene {
        WindowGroup {
            AppContentView(
                backgroundService: backgroundService,
                modelContainer: modelContainer
            )
            .environment(backgroundState)
            .environment(tabRouter)
            .environment(searchState)
            .environment(workflowService)
            .environment(drawerRouter)
            .environment(portalService)
            .environment(authService)
            .environment(subscriptionManager)
            .environment(cloudKitSharingService)
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - App Content View (Initializes BusinessManager)

/// Wrapper view that creates BusinessManager with access to modelContainer
private struct AppContentView: View {
    let backgroundService: BackgroundService
    let modelContainer: ModelContainer
    
    @State private var businessManager: BusinessManager?
    
    var body: some View {
        Group {
            if let businessManager {
                RootView(backgroundService: backgroundService)
                    .environment(businessManager)
            } else {
                ProgressView("Initializing...")
            }
        }
        .task {
            if businessManager == nil {
                businessManager = BusinessManager(container: modelContainer)
            }
        }
    }
}

// MARK: - Root View (Auth Gate)

/// Root view that shows AuthView or MainTabView based on authentication state
struct RootView: View {
    @Environment(AuthService.self) private var authService
    @Environment(BusinessManager.self) private var businessManager
    
    let backgroundService: BackgroundService
    
    var body: some View {
        Group {
            switch authService.authState {
            case .unknown:
                // Loading state while checking existing session
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    ProgressView("Loading...")
                }
                
            case .signedOut:
                // Show sign-in view
                AuthView()
                
            case .signedIn(let userID):
                // Show main app
                MainTabView(backgroundService: backgroundService)
                    .onAppear {
                        // Configure business manager with authenticated user
                        businessManager.configureForAuthenticatedUser(
                            appleUserID: userID,
                            credentials: authService.credentials
                        )
                    }
            }
        }
        .animation(.easeInOut, value: authService.authState)
    }
}
