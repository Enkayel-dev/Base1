# Base1 - Business Management iOS App

## Project Overview
SwiftUI + SwiftData business management app with animated mesh gradient backgrounds, glass morphism UI, tab-based navigation, and a workflow engine. Targets iOS with multi-tenancy support.

## Critical Rules
- **NEVER create new files without first confirming existing files.** Use `find` or `ls` to verify a file doesn't already exist before creating one.
- **NEVER duplicate models, services, or views.** All types are defined once. Check this index before writing.
- **NEVER move files between folders** without explicit user instruction.
- **Read before writing.** Always read a file's current contents before modifying it.
- **Preserve the architecture.** Shared Models go in `Shared/Models/`, Shared Services in `Shared/Services/`, Feature-specific files go in `Features/<FeatureName>/`.
- **Modern Swift (6.x) Strictness**: Never leave unused variables (e.g., `let rate = ...` if not used). Swift 6 will fail or warn aggressively.
- **iOS 26.0+ Screen Access**: NEVER use `UIScreen.main`. It is deprecated. Derive screen bounds from the active scene context (e.g., `windowScene.screen.bounds`).
- **Decimal Formatting**: When using `NSDecimalNumber` for currency or string interpolation with nil-coalescing, always parenthesize the operation: `(optionalDecimal ?? 0) as NSDecimalNumber`.
- **NEVER attempt to build the project.** Do not run `xcodebuild` or any build commands. The user handles builds in Xcode.
- **NEVER act on diagnostics/warnings** unless the user explicitly mentions them. Ignore SourceKit diagnostics, linter warnings, and similar automated messages.
- **Always update CLAUDE.md** when completing tasks that change architecture, add files, or establish new patterns.

## Build & Run
- **Platform:** iOS (SwiftUI, SwiftData)
- **Xcode project:** `Base1.xcodeproj`

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
| **Liquid Glass** | iOS 26.2 | Glassmorphism — dynamic materials and morphing containers (`GlassEffectContainer`) |

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
├── Clients/          ← Tab1View, AddClientView, ClientRowView, ClientDetailView, EmptyClientsView
├── Schedule/         ← Tab2View, AddAppointmentView, AppointmentRowView, EmptyScheduleView
├── Projects/         ← Tab3View, AddProjectView, ProjectRowView, ProjectDetailView, AddScopeItemView, ScopeItemRowView, EmptyProjectsView
├── Resources/        ← Tab4View, AddEquipmentView, AddMaterialView, AddVehicleView, AddToolView, ResourceRowView, EmptyResourcesView
├── Finances/         ← Tab5View (placeholder)
├── Workflow/         ← WorkflowModels, WorkflowService, WorkflowMiniCard, WorkflowViewFactory (stub)
├── Background/       ← AnimatedMeshBackground, MeshScheme, BackgroundState, BackgroundService, BackgroundCoordinator (unused)
├── Navigation/       ← MainTabView, TabRouter, DrawerRouter, DrawerViewFactory, BottomBarView, CustomBottomTabBar, SearchBar, SearchState, BusinessLogo, SettingsButton
└── Settings/         ← SettingsView, BusinessProfile, MemberRowView, InviteMemberView, JobTypeListView, AddJobTypeView, JobTypeDetailView, AddScopeItemTemplateView
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
                .environment(drawerRouter)
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

#### Pattern: DrawerRouter (Centralized Modal Presentation)

All modal content uses a centralized `DrawerRouter` (@Observable service) instead of `.sheet()`. The `SideDrawer` component slides from the right, occupies the center 1/3 of screen height, and uses `.ultraThinMaterial`. Drawers render as an overlay on `MainTabView` — outside the offset-based tab ZStack — so they always cover the full screen regardless of tab position.

**DrawerRouter** manages a stack of `DrawerDestination` enum values. Views call `drawerRouter.present(.destination)` to open drawers. The stack supports nesting (drawer opens another drawer). `DrawerViewFactory` maps enum cases to SwiftUI views.

```swift
// Feature view — present a drawer via the router
@Environment(DrawerRouter.self) private var drawerRouter

Button { drawerRouter.present(.addClient) }

// Item-based — pass model as associated value
.onTapGesture { drawerRouter.present(.clientDetail(client)) }

// Content view — dismiss via environment action (unchanged)
@Environment(\.dismissDrawer) private var dismiss
```

**Why centralized, not per-view:**
- Tab views use offset-based transitions; `.overlay`-based drawers would shift with the tab content
- Nested drawers (e.g., JobTypeList > JobTypeDetail > AddScopeItemTemplate) need full-screen rendering
- Single point of control for all drawer animations, z-ordering, and lifecycle

#### Pattern: Liquid Glass & Morphing UI

Base1 leverages the **Liquid Glass framework (iOS 26+)** for premium, fluid UI elements. This involves using `GlassEffectContainer` to group multiple glass views and enable morphing transitions.

**Key Components:**
- **`GlassEffectContainer`**: A container that blends multiple glass elements together and coordinates morphing animations.
- **`.glassEffect()`**: Modifier to apply Liquid Glass materials (e.g., `.regular.interactive()`).
- **`.glassEffectID(_:in:)`**: Used with `@Namespace` to identify elements for morphing transitions.

**Implementation Example:**
```swift
GlassEffectContainer(spacing: 8) {
    HStack {
        ForEach(options) { option in
            Button { /* select */ } label: {
                Text(option.title)
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .glassEffectID(option.id, in: glassNS)
            }
        }
    }
}
```

**Why Liquid Glass:**
- Provides a sense of depth and fluidity beyond standard `ultraThinMaterial`.
- Allows UI elements (like filter bubbles) to "melt" and reform as they move between states or across rows.
- Highly performant rendering on iOS 26+ hardware.

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
| `Business.swift` | `Business` | Root entity, owns clients/projects/resources/templates/members/jobTypes/scopeItemTemplates. Fields: businessKey, ownerAppleUserID, name, ownerName, email?, phone?, address?, taxNumber?, logoData?, createdAt |
| `Client.swift` | `Client`, `ClientStatus` | Customer with status (lead/active/closed). Has businessKey |
| `Project.swift` | `Project`, `ProjectStatus` | Project tracking with budget/timeline. Has businessKey, projectTypeRaw (job type name), scopeItems relationship, assignedMembers many-to-many, computed totalScopeCost, totalLaborHours, hasInventoryIssues. No priority field. **Has `isLocked` flag to prevent edits after estimate generation.** |
| `Invoice.swift` | `Invoice`, `InvoiceStatus` | Billing (draft/sent/paid/overdue/cancelled). Has businessKey |
| `Appointment.swift` | `Appointment`, `AppointmentType` | Scheduling (consultation/siteVisit/meeting/followUp/delivery). Has businessKey |
| `Resource.swift` | `Resource`, `ResourceCategory` | Equipment/materials/vehicles/tools with category-specific fields. Equipment: equipmentMaterials relationship. Material: materialTypeName, variantLabel, parentMaterial/materialVariants self-referential parent-child. Vehicle: vehicleMake, vehicleModel, startingKilometers, serviceNotes. Tool: assignedVehicle relationship, isShopTool. Common: businessKey, scopeItems relationship, computed allocatedQuantity, availableQuantity, isMaterialType, isMaterialVariant, toolLocationLabel, vehicleDisplayLabel |
| `ScopeItem.swift` | `ScopeItem`, `ScopeItemStatus` | Project scoping line items — bridges Project ↔ Resource. Fields: quantityNeeded, laborHours, costMarkup, status (pending/ordered/fulfilled). Computed: estimatedCost, inventoryShortfall (global allocation). Has businessKey |
| `Member.swift` | `Member`, `MemberRole`, `InviteStatus` | Team members with roles (owner/admin/member). Fields: businessKey, email, displayName, roleRaw, inviteStatusRaw, invitedAt, acceptedAt?, createdAt, updatedAt. Relationships: business, assignedProjects (many-to-many with Project). Computed: role, inviteStatus, initials |
| `JobType.swift` | `JobType` | Business-created project types (e.g., Renovation, New Build, Repair). Fields: businessKey, name, icon, sortOrder, createdAt. Relationships: business, scopeItemTemplates |
| `ScopeItemTemplate.swift` | `ScopeItemTemplate` | Reusable scope item library entries linked to Resources. Fields: businessKey, name, defaultQuantity, defaultLaborHours?, defaultCostMarkup?, notes?, createdAt. Relationships: resource, business, jobType |
| `WorkflowTemplate.swift` | `WorkflowTemplate`, `WorkflowStepTemplate`, `WorkflowCategory` | Reusable workflow blueprints. Has businessKey |
| `ProjectMilestone.swift` | `ProjectMilestone`, `MilestoneType` | Project lifecycle events (created, site visit, estimate sent, etc.). Marked as dots on the schedule timeline. |
| `SampleData.swift` | Extensions on all models | Preview/test data factories. All factories accept businessKey param |
| `Schema/Base1SchemaV1.swift` | `Base1SchemaV1`, `Base1MigrationPlan` | SwiftData schema versioning |

#### Model Relationships
```
Business 1──* Client, Project, Resource, WorkflowTemplate, Member, JobType, ScopeItemTemplate
Client   1──* Project, Appointment, Invoice, Workflow
Project  *──* Resource (legacy)
Project  *──* Member (assigned team)
Project  1──* ScopeItem *──1 Resource
Project  1──* Invoice, Appointment, Workflow
WorkflowTemplate 1──* WorkflowStepTemplate
WorkflowTemplate 1──* Workflow (instances)
Workflow 1──* WorkflowStep
Resource(Equipment) *──* Resource(Material) (equipmentMaterials / usedByEquipment)
Resource(Material)  1──* Resource(Material) (parentMaterial / materialVariants, cascade)
Resource(Tool)      *──1 Resource(Vehicle) (assignedVehicle / assignedTools)
JobType  1──* ScopeItemTemplate *──1 Resource
```

### Services (`Shared/Services/`)
| File | Type | Purpose |
|------|------|---------|
| `BusinessManager.swift` | `BusinessManager` (@Observable) | Business entity CRUD, multi-tenancy, bootstrapping |
| `ClientService.swift` | `ClientService` (@Observable) | Client filtering by status |
| `AppointmentService.swift` | `AppointmentService` (@Observable), `ScheduleFilter` | Appointment filtering (all/upcoming/past/cancelled) and day grouping |

### UI Layer

#### Navigation & Chrome (`Features/Navigation/`)
| File | Type | Purpose |
|------|------|---------|
| `MainTabView.swift` | `MainTabView` | Root view — ZStack with background, tab content, drawer overlay, nav buttons |
| `Components/TabRouter.swift` | `TabRouter` (@Observable) | Tab selection state, offset-based slide animations |
| `Components/DrawerRouter.swift` | `DrawerRouter` (@Observable), `DrawerDestination` | Centralized drawer presentation — stack-based, supports nesting. All views call `drawerRouter.present(.destination)`. Added `.projectEstimate` for PDF preview. |
| `Components/DrawerViewFactory.swift` | `DrawerViewFactory` | Maps `DrawerDestination` enum cases to SwiftUI content views |
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
| `Features/Clients/Tab1View.swift` | `Tab1View` | Clients | Client list with filter picker + add client side drawer |
| `Features/Clients/AddClientView.swift` | `AddClientView` | Clients | Add client form |
| `Features/Clients/ClientRowView.swift` | `ClientRowView` | Clients | Client list row |
| `Features/Clients/ClientDetailView.swift` | `ClientDetailView` | Clients | Client detail drawer — contact info, linked projects, appointments |
| `Features/Clients/EmptyClientsView.swift` | `EmptyClientsView` | Clients | Empty state |
| `Features/Schedule/Tab2View.swift` | `Tab2View` | Schedule | Calendar day view with date selector, all-day banner, DayTimelineView + add appointment side drawer. Queries active projects for timeline display. |
| `Features/Schedule/DayTimelineView.swift` | `DayTimelineView` | Schedule | Apple Calendar-style day timeline — hour grid, vertical project timeline lines with milestone dots on the left, positioned event blocks, overlap layout, now-line |
| `Features/Schedule/AddAppointmentView.swift` | `AddAppointmentView` | Schedule | Add appointment form — type, date/time, all-day, location, client/project linking, reminders |
| `Features/Schedule/AppointmentRowView.swift` | `AppointmentRowView` | Schedule | Appointment list row — type icon, time, client, location, status indicators |
| `Features/Schedule/EmptyScheduleView.swift` | `EmptyScheduleView` | Schedule | Empty state |
| `Features/Projects/Tab3View.swift` | `Tab3View` | Projects | Project list with status filter picker (LiquidGlassFilterPicker) + add project side drawer |
| `Features/Projects/AddProjectView.swift` | `AddProjectView` | Projects | Add project form — client first, job type picker, auto-title, budget, start/due dates, team member assignment, description. Status auto-set to planning, scope items pre-filled from template |
| `Features/Projects/ProjectRowView.swift` | `ProjectRowView` | Projects | Project list row — status badge, job type label, client name, date range, overdue indicator |
| `Features/Projects/EmptyProjectsView.swift` | `EmptyProjectsView` | Projects | Empty state |
| `Features/Projects/ProjectDetailView.swift` | `ProjectDetailView` | Projects | Project detail side drawer — header, assigned team section, scope items list, summary cards (cost, labor, inventory warnings) |
| `Features/Projects/AddScopeItemView.swift` | `AddScopeItemView` | Projects | Add scope item form — resource picker, quantity, labor hours, cost markup, live cost estimate, status |
| `Features/Projects/ProjectEstimatePDFView.swift` | `ProjectEstimatePDFView` | Projects | Letter-formatted (8.5" x 11") estimate view for PDF generation |
| `Features/Projects/PDFPreviewView.swift` | `PDFPreviewView` | Projects | Drawer using `PDFView` and `ImageRenderer` to generate and display estimate PDFs |
| `Features/Projects/ScopeItemRowView.swift` | `ScopeItemRowView` | Projects | Scope item row — resource icon, quantity, cost, status badge, inventory shortfall warning |
| `Features/Resources/Tab4View.swift` | `Tab4View`, `ResourceListSheet` | Resources | 2x2 category grid (Equipment/Materials/Vehicles/Tools) — each card has Add and Open buttons. ResourceListSheet shows filtered list per category |
| `Features/Resources/AddEquipmentView.swift` | `AddEquipmentView` | Resources | Add equipment form — name, description, materials used (multi-select), quantity, unit cost, availability, notes |
| `Features/Resources/AddMaterialView.swift` | `AddMaterialView` | Resources | Add material form — two modes: "New Type" (creates material type) or "Add Variant" (picks parent type, enters variant label, quantity, unit cost) |
| `Features/Resources/AddVehicleView.swift` | `AddVehicleView` | Resources | Add vehicle form — name, make, model, starting kilometers, service notes, availability |
| `Features/Resources/AddToolView.swift` | `AddToolView` | Resources | Add tool form — name, location (Shop/Vehicle segmented), quantity, notes |
| `Features/Resources/ResourceRowView.swift` | `ResourceRowView` | Resources | Resource list row — category-specific detail: equipment shows linked materials, material shows variant info, vehicle shows make/model/km, tool shows location |
| `Features/Resources/EmptyResourcesView.swift` | `EmptyResourcesView` | Resources | Empty state |
| `Features/Finances/Tab5View.swift` | `Tab5View` | Finances | Finances tab (placeholder) |
| `Features/Settings/SettingsView.swift` | `SettingsView` | Settings | Settings screen (mock) |
| `Features/Settings/BusinessProfile.swift` | `BusinessProfile` | Settings | Business info editing — inline fields, PhotosPicker logo, team management section, job types & templates link |
| `Features/Settings/MemberRowView.swift` | `MemberRowView` | Settings | Team member list row — avatar initials, name, email, role badge, invite status |
| `Features/Settings/InviteMemberView.swift` | `InviteMemberView` | Settings | Invite member form side drawer — email, display name, role picker (admin/member) |
| `Features/Settings/JobTypeListView.swift` | `JobTypeListView` | Settings | Job type list — manage job types and their scope item templates |
| `Features/Settings/AddJobTypeView.swift` | `AddJobTypeView` | Settings | Add job type form — name, icon picker |
| `Features/Settings/JobTypeDetailView.swift` | `JobTypeDetailView` | Settings | Job type detail — shows scope item templates, add new ones |
| `Features/Settings/AddScopeItemTemplateView.swift` | `AddScopeItemTemplateView` | Settings | Add scope item template — resource picker, default quantity, labor hours, cost markup |

#### Shared Components (`Shared/UI/Components/`)
| File | Type | Purpose |
|------|------|---------|
| `LabeledTextField.swift` | `LabeledTextField` | Shared labeled text field with icon + keyboard type |
| `BindingExtensions.swift` | `Binding<String?>.orEmpty` | Optional string binding helper |
| `LiquidGlassFilterPicker.swift` | `LiquidGlassFilterPicker<Filter: Filterable>`, `Filterable` protocol, `FilterOption` (Clients), `ProjectFilterOption` (Projects) | Generic glass morphism segmented control — reusable across any feature with a `Filterable` enum |
| `SideDrawer.swift` | `SideDrawer<Content>`, `DrawerDismissAction`, `NavigationBackgroundCleaner` | Side drawer rendering component — slides from right, center 1/3 height, ultraThinMaterial, dimmed backdrop. Includes `NavigationBackgroundCleaner` (UIViewRepresentable) that walks the responder chain to clear `NavigationStack`'s opaque background so the material shows through. Used by `MainTabView` to render content from `DrawerRouter`. Content views use `@Environment(\.dismissDrawer)` to dismiss |

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
│   │   ├── ScopeItem.swift
│   │   ├── Member.swift
│   │   ├── JobType.swift
│   │   ├── ScopeItemTemplate.swift
│   │   ├── WorkflowTemplate.swift
│   │   ├── ProjectMilestone.swift
│   │   ├── SampleData.swift
│   │   └── Schema/
│   │       └── Base1SchemaV1.swift
│   ├── Services/
│   │   ├── BusinessManager.swift
│   │   ├── ClientService.swift
│   │   └── AppointmentService.swift
│   ├── Design/
│   │   └── DesignConstants.swift
│   └── UI/
│       └── Components/
│           ├── LabeledTextField.swift
│           ├── BindingExtensions.swift
│           ├── LiquidGlassFilterPicker.swift
│           └── SideDrawer.swift
└── Features/
    ├── Navigation/
    │   ├── MainTabView.swift
    │   └── Components/
    │       ├── BottomBarView.swift
    │       ├── BusinessLogo.swift
    │       ├── CustomBottomTabBar.swift
    │       ├── DrawerRouter.swift
    │       ├── DrawerViewFactory.swift
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
    │   ├── Tab1View.swift
    │   ├── AddClientView.swift
    │   ├── ClientRowView.swift
    │   ├── ClientDetailView.swift
    │   └── EmptyClientsView.swift
    ├── Schedule/
    │   ├── Tab2View.swift
    │   ├── AddAppointmentView.swift
    │   ├── AppointmentRowView.swift
    │   └── EmptyScheduleView.swift
    ├── Projects/
    │   ├── Tab3View.swift
    │   ├── AddProjectView.swift
    │   ├── ProjectRowView.swift
    │   ├── ProjectDetailView.swift
    │   ├── AddScopeItemView.swift
    │   ├── ScopeItemRowView.swift
    │   └── EmptyProjectsView.swift
    ├── Resources/
    │   ├── Tab4View.swift
    │   ├── AddEquipmentView.swift
    │   ├── AddMaterialView.swift
    │   ├── AddVehicleView.swift
    │   ├── AddToolView.swift
    │   ├── ResourceRowView.swift
    │   └── EmptyResourcesView.swift
    ├── Finances/
    │   └── Tab5View.swift
    └── Settings/
        ├── SettingsView.swift
        ├── BusinessProfile.swift
        ├── MemberRowView.swift
        ├── InviteMemberView.swift
        ├── JobTypeListView.swift
        ├── AddJobTypeView.swift
        ├── JobTypeDetailView.swift
        └── AddScopeItemTemplateView.swift
```
