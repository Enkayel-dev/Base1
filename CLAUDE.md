# Base1 - Business Management iOS App

## Project Overview
SwiftUI + SwiftData business management app with animated mesh gradient backgrounds, glass morphism UI, tab-based navigation, and a workflow engine. Targets iOS with multi-tenancy support.

## Critical Rules
- **NEVER create new files without first confirming existing files.** Use `find` or `ls` to verify a file doesn't already exist before creating one.
- **NEVER duplicate models, services, or views.** All types are defined once. Check this index before writing.
- **NEVER move files between folders** without explicit user instruction.
- **Read before writing.** Always read a file's current contents before modifying it.
- **Preserve the architecture.** Shared Models go in `Shared/Models/`, Shared Services in `Shared/Services/`, Feature-specific files go in `Features/<FeatureName>/`.

## Build & Run
- **Platform:** iOS (SwiftUI, SwiftData)
- **Xcode project:** `Base1.xcodeproj`
- **Build:** `xcodebuild -project Base1.xcodeproj -scheme Base1 -destination 'platform=iOS Simulator,name=iPhone 16' build`
- **No package manager dependencies** — pure Apple frameworks

---

## Patterns & Frameworks

> **Year:** 2026 · **Xcode:** 26.2 · **macOS:** 26.2 · **iOS:** 26.2  
> **Philosophy:** Apple Native First — no third-party dependencies. All patterns follow modern Apple platform conventions.

### Frameworks

| Framework | Version | Role |
|-----------|---------|------|
| **SwiftUI** | iOS 26.2 | Declarative UI — all views are `struct` conforming to `View` |
| **SwiftData** | iOS 26.2 | Persistence — `@Model` macro for domain entities, `@Query` for reactive fetching |
| **Observation** | iOS 26.2 | State management — `@Observable` macro replaces `ObservableObject`/`@Published` |
| **Swift** | 6.x | Language — strict concurrency, `@MainActor` isolation |

### Architecture: Modern MV (Model–View)

Base1 uses the **MV (Model–View) pattern** — Apple's preferred approach for SwiftUI apps. Views interact directly with `@Observable` model/service objects injected through the environment. There is **no separate ViewModel layer**.

**Why MV, not MVVM:**
- SwiftUI views are lightweight value types, rebuilt frequently by the framework
- `@Observable` + `@Environment` gives views direct, efficient access to shared state
- A ViewModel layer adds indirection without benefit when SwiftUI already manages view lifecycle and state diffing
- `@Query` provides reactive, filtered data directly in the View — no ViewModel needed to wrap it

#### Pattern: `@Observable` Services as Shared State

Services are `@Observable` classes injected into the environment from the app entry point. Views read from them directly.

```swift
// Shared/Services/BusinessManager.swift
@MainActor @Observable
final class BusinessManager {
    private(set) var currentBusiness: Business?
    private(set) var businessKey: String?
    private let context: ModelContext

    init(container: ModelContainer) {
        self.context = container.mainContext
        loadOrBootstrapBusiness()
    }
}
```

```swift
// Features/Clients/ClientsView.swift  (View reads directly from service)
struct ClientsView: View {
    @Environment(BusinessManager.self) private var businessManager
    @Query(sort: \Client.createdAt, order: .reverse)
    private var allClients: [Client]
    // ...
}
```

#### Pattern: `@Model` for SwiftData Entities

All domain models use the `@Model` macro. Schema versioning is explicit via `VersionedSchema`.

```swift
// Shared/Models/Client.swift
@Model
final class Client {
    var businessKey: String
    var name: String
    var status: ClientStatus
    var createdAt: Date
    // ...
}
```

#### Pattern: Feature-Centric File Organization

Files are grouped by **feature** (Clients, Workflow, Settings, etc.) rather than by type (Views, Controllers). Each feature folder contains all the views, subviews, and feature-specific logic for that domain.

```
Features/
├── Clients/          ← ClientsView, AddClientView, ClientRowView, EmptyClientsView
├── Schedule/         ← ScheduleView
├── Workflow/         ← WorkflowModels, WorkflowService, WorkflowMiniCard
└── Settings/         ← SettingsView, BusinessProfile
```

#### Pattern: Environment Injection from App Root

All shared services are created once at the app entry point and injected via `.environment()`. Features access them with `@Environment`.

```swift
// App/Base1App.swift
@main
struct Base1App: App {
    var body: some Scene {
        WindowGroup {
            MainTabView(backgroundService: BackgroundService())
                .environment(businessManager)
                .environment(tabRouter)
                .environment(searchState)
                .environment(workflowService)
                .environment(backgroundState)
        }
        .modelContainer(for: Base1SchemaV1.models)
    }
}
```

#### Pattern: Offset-Based Tab Navigation

Custom tab switching using offset calculations rather than native `TabView`. Enables full control over transition animations.

```swift
// Features/Navigation/Components/TabRouter.swift
@Observable
final class TabRouter {
    var selectedTab: Int = 0
    var isSettingsActive: Bool = false
    var isBusinessProfileActive: Bool = false

    func offsetForTab(_ tab: Int, screenWidth: CGFloat) -> CGFloat {
        if isSettingsActive { return -screenWidth }
        if isBusinessProfileActive { return screenWidth }
        if selectedTab == tab { return 0 }
        else if selectedTab > tab { return -screenWidth }
        else { return screenWidth }
    }
}
```

#### Pattern: Centralized Design Constants

All spacing, sizing, and animation values live in a single `DesignConstants` enum to avoid magic numbers.

```swift
// Shared/Design/DesignConstants.swift
enum DesignConstants {
    enum BottomBar {
        static let cornerRadius: CGFloat = 48
        static let horizontalPadding: CGFloat = 8
    }
    enum Animation {
        static let tabSwitchResponse: Double = 0.35
        static let tabSwitchDamping: Double = 0.85
    }
}
```

#### Pattern: Multi-Tenancy via `businessKey`

Every domain model carries a `businessKey` field. All queries and factories accept `businessKey` as a parameter, enabling future multi-business support.

---

## Architecture

### Entry Point
- `App/Base1App.swift` — Creates ModelContainer (Base1SchemaV1), initializes all services, injects into environment for MainTabView

### Data Layer (`Shared/Models/`)
All models use `@Model` (SwiftData). Schema defined in `Schema/Base1SchemaV1.swift`.

| File | Type | Purpose |
|------|------|---------|
| `Business.swift` | `Business` | Root entity, owns clients/projects/resources/templates. Fields: businessKey, ownerAppleUserID, name, ownerName, email?, phone?, address?, notes?, taxNumber?, logoData?, createdAt |
| `Client.swift` | `Client`, `ClientStatus` | Customer with status (lead/active/closed). Has businessKey |
| `Project.swift` | `Project`, `ProjectStatus`, `ProjectPriority` | Project tracking with budget/timeline. Has businessKey |
| `Invoice.swift` | `Invoice`, `InvoiceStatus` | Billing (draft/sent/paid/overdue/cancelled). Has businessKey |
| `Appointment.swift` | `Appointment`, `AppointmentType` | Scheduling (consultation/siteVisit/meeting/followUp/delivery). Has businessKey |
| `Resource.swift` | `Resource`, `ResourceCategory` | Equipment/materials/vehicles/tools. Has businessKey |
| `WorkflowTemplate.swift` | `WorkflowTemplate`, `WorkflowStepTemplate`, `WorkflowCategory` | Reusable workflow blueprints. Has businessKey |
| `SampleData.swift` | Extensions on all models | Preview/test data factories. All factories accept businessKey param |
| `Schema/Base1SchemaV1.swift` | `Base1SchemaV1`, `Base1MigrationPlan` | SwiftData schema versioning |

#### Model Relationships
```
Business 1──* Client, Project, Resource, WorkflowTemplate
Client   1──* Project, Appointment, Invoice, Workflow
Project  *──* Resource
Project  1──* Invoice, Appointment, Workflow
WorkflowTemplate 1──* WorkflowStepTemplate
WorkflowTemplate 1──* Workflow (instances)
Workflow 1──* WorkflowStep
```

### Services (`Shared/Services/`)
| File | Type | Purpose |
|------|------|---------|
| `BusinessManager.swift` | `BusinessManager` (@Observable) | Business entity CRUD, multi-tenancy, bootstrapping |
| `ClientService.swift` | `ClientService` (@Observable) | Client filtering by status |

### UI Layer

#### Navigation & Chrome (`Features/Navigation/`)
| File | Type | Purpose |
|------|------|---------|
| `MainTabView.swift` | `MainTabView` | Root view — ZStack with background, tab content, nav buttons |
| `Components/TabRouter.swift` | `TabRouter` (@Observable) | Tab selection state, offset-based slide animations |
| `Components/BottomBarView.swift` | `BottomBarView` | Bottom bar container (search bar, workflow card, tab bar) |
| `Components/CustomBottomTabBar.swift` | `CustomBottomTabBar` | 5-tab bar with matched geometry selection indicator |
| `Components/SearchBar.swift` | `SearchBar` | Search input with auto-focus |
| `Components/SearchState.swift` | `SearchState` (@Observable) | Search text and active state |
| `Components/BusinessLogo.swift` | `BusinessLogo` | Top-left profile button |
| `Components/SettingsButton.swift` | `SettingsButton` | Top-right settings button |

#### Workflow System (`Features/Workflow/`)
| File | Type | Purpose |
|------|------|---------|
| `WorkflowModels.swift` | `Workflow`, `WorkflowStep` (@Model) | Runtime workflow instances (SwiftData) |
| `WorkflowService.swift` | `WorkflowService` (@Observable) | Workflow lifecycle (start/pause/skip/complete) |
| `WorkflowMiniCard.swift` | `WorkflowMiniCard`, `WorkflowProgressBar` | Compact workflow display in bottom bar |
| `WorkflowViewFactory.swift` | `WorkflowViewFactory` | Maps step viewKey strings to SwiftUI views (stub) |

#### Feature Views
| File | Type | Feature | Purpose |
|------|------|---------|---------|
| `Features/Clients/ClientsView.swift` | `ClientsView` | Clients | Client list with filter picker + add client sheet |
| `Features/Clients/AddClientView.swift` | `AddClientView` | Clients | Add client form |
| `Features/Clients/ClientRowView.swift` | `ClientRowView` | Clients | Client list row |
| `Features/Clients/EmptyClientsView.swift` | `EmptyClientsView` | Clients | Empty state |
| `Features/Schedule/ScheduleView.swift` | `ScheduleView` | Schedule | Schedule tab (placeholder) |
| `Features/Projects/ProjectsView.swift` | `ProjectsView` | Projects | Projects tab (placeholder) |
| `Features/Resources/ResourcesView.swift` | `ResourcesView` | Resources | Resources tab (placeholder) |
| `Features/Finances/FinancesView.swift` | `FinancesView` | Finances | Finances tab (placeholder) |
| `Features/Settings/SettingsView.swift` | `SettingsView` | Settings | Settings screen (mock) |
| `Features/Settings/BusinessProfile.swift` | `BusinessProfile` | Settings | Business info editing — inline fields, PhotosPicker logo |

#### Shared Components (`Shared/UI/Components/`)
| File | Type | Purpose |
|------|------|---------|
| `LabeledTextField.swift` | `LabeledTextField` | Shared labeled text field with icon + keyboard type |
| `BindingExtensions.swift` | `Binding<String?>.orEmpty` | Optional string binding helper |
| `LiquidGlassFilterPicker.swift` | `LiquidGlassFilterPicker`, `FilterOption` | Glass morphism segmented control |

#### Design System (`Shared/Design/`)
| File | Type | Purpose |
|------|------|---------|
| `DesignConstants.swift` | `DesignConstants` | Centralized spacing/sizing/animation constants |

#### Background Animation (`Features/Background/`)
| File | Type | Purpose |
|------|------|---------|
| `AnimatedMeshBackground.swift` | `AnimatedMeshBackground` | 3x3 MeshGradient with animated center point |
| `Components/MeshScheme.swift` | `MeshScheme` | Color scheme enum (gold/amber/blue/crimson/mint/violet/teal) |
| `Components/BackgroundState.swift` | `BackgroundState` (@Observable) | Current scheme + transition progress |
| `Components/BackgroundService.swift` | `BackgroundService` | Maps tab index to MeshScheme |
| `Components/BackgroundCoordinator.swift` | `BackgroundCoordinator` (@Observable) | Transition coordination (currently unused) |

### Tab Mapping
| Index | Tab | View | Background | Color |
|-------|-----|------|------------|-------|
| 0 | Clients | ClientsView | gold | Gold |
| 1 | Schedule | ScheduleView | amber | Amber |
| 2 | Projects | ProjectsView | blue | Blue |
| 3 | Resources | ResourcesView | crimson | Crimson |
| 4 | Finances | FinancesView | mint | Mint |
| — | Settings | SettingsView | violet | Violet |
| — | Profile | BusinessProfile | teal | Teal |

## Directory Structure
```
Base1/
├── Assets.xcassets/
├── App/
│   ├── Base1App.swift
│   └── ContentView.swift
├── Shared/
│   ├── Models/
│   │   ├── Business.swift
│   │   ├── Client.swift
│   │   ├── Project.swift
│   │   ├── Invoice.swift
│   │   ├── Appointment.swift
│   │   ├── Resource.swift
│   │   ├── WorkflowTemplate.swift
│   │   ├── SampleData.swift
│   │   └── Schema/
│   │       └── Base1SchemaV1.swift
│   ├── Services/
│   │   ├── BusinessManager.swift
│   │   └── ClientService.swift
│   ├── Design/
│   │   └── DesignConstants.swift
│   └── UI/
│       └── Components/
│           ├── LabeledTextField.swift
│           ├── BindingExtensions.swift
│           └── LiquidGlassFilterPicker.swift
└── Features/
    ├── Navigation/
    │   ├── MainTabView.swift
    │   └── Components/
    │       ├── BottomBarView.swift
    │       ├── BusinessLogo.swift
    │       ├── CustomBottomTabBar.swift
    │       ├── SearchBar.swift
    │       ├── SearchState.swift
    │       ├── SettingsButton.swift
    │       └── TabRouter.swift
    ├── Workflow/
    │   ├── WorkflowMiniCard.swift
    │   ├── WorkflowModels.swift
    │   ├── WorkflowService.swift
    │   └── WorkflowViewFactory.swift
    ├── Background/
    │   ├── AnimatedMeshBackground.swift
    │   └── Components/
    │       ├── BackgroundCoordinator.swift
    │       ├── BackgroundService.swift
    │       ├── BackgroundState.swift
    │       └── MeshScheme.swift
    ├── Clients/
    │   ├── ClientsView.swift
    │   ├── AddClientView.swift
    │   ├── ClientRowView.swift
    │   └── EmptyClientsView.swift
    ├── Schedule/
    │   └── ScheduleView.swift
    ├── Projects/
    │   └── ProjectsView.swift
    ├── Resources/
    │   └── ResourcesView.swift
    ├── Finances/
    │   └── FinancesView.swift
    └── Settings/
        ├── SettingsView.swift
        └── BusinessProfile.swift
```
