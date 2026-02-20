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

> **Year:** 2026 · **Xcode:** 26.3 · **macOS:** 26.3 · **iOS:** 26.3
> **Philosophy:** Apple Native First — no third-party dependencies. All patterns follow modern Apple platform conventions.

### Frameworks

| Framework | Version | Role |
|-----------|---------|------|
| **SwiftUI** | iOS 26.3 | Declarative UI — all views are `struct` conforming to `View` |
| **SwiftData** | iOS 26.3 | Persistence — `@Model` macro for domain entities, `@Query` for reactive fetching |
| **Observation** | iOS 26.3 | State management — `@Observable` macro replaces `ObservableObject`/`@Published` |
| **Swift** | 6.x | Language — strict concurrency, `@MainActor` isolation |
| **Liquid Glass** | iOS 26.3 | Glassmorphism — dynamic materials and morphing containers (`GlassEffectContainer`) |

### Architecture: Modern MV (Model–View)

Base1 uses the **MV (Model–View) pattern** — Apple's preferred approach for SwiftUI apps. Views interact directly with `@Observable` model/service objects injected through the environment. There is **no separate ViewModel layer**.

**Why MV, not MVVM:**
- SwiftUI views are lightweight value types, rebuilt frequently by the framework
- `@Observable` + `@Environment` gives views direct, efficient access to shared state
- A ViewModel layer adds indirection without benefit when SwiftUI already manages view lifecycle and state diffing
- `@Query` provides reactive, filtered data directly in the View — no ViewModel needed to wrap it

#### Pattern: `@MainActor @Observable` Services as Shared State

All `@Observable` services that drive UI state must be marked `@MainActor`. Services are created once at the app entry point and injected via `.environment()`. Views read from them directly.

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
// Features/Clients/Tab1View.swift  (View reads directly from service)
struct Tab1View: View {
    @Environment(BusinessManager.self) private var businessManager
    @Query(sort: \Client.createdAt, order: .reverse)
    private var allClients: [Client]
    // ...
}
```

#### Pattern: Stateless Free Functions for Simple Filtering

Services that only filter or transform data (no mutable state) are **top-level free functions**, not `@Observable` classes. This eliminates unnecessary object allocation and avoids the anti-pattern of stateless `@Observable` classes.

```swift
// Shared/Services/ClientService.swift
func filteredClients(_ allClients: [Client], filter: FilterOption) -> [Client] {
    switch filter {
    case .all:      return allClients
    case .lead:     return allClients.filter { $0.status == .lead }
    case .active:   return allClients.filter { $0.status == .active }
    case .closed:   return allClients.filter { $0.status == .closed }
    }
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
├── Auth/             ← AuthView (Sign in with Apple), SubscriptionView (StoreKit 2 subscription management)
├── Clients/          ← Tab1View, AddClientView, ClientRowView, ClientDetailView, EmptyClientsView
├── Schedule/         ← Tab2View, AddAppointmentView, AddScheduleView, AppointmentRowView, DayTimelineView, EmptyScheduleView
├── Projects/         ← Tab3View, AddProjectView, AddMeasurementView, AddProjectPhotoView, ProjectRowView, ProjectDetailView, AddScopeItemView, ScopeItemRowView, EmptyProjectsView, PDFPreviewView, ProjectEstimatePDFView, ShareEstimateView
├── Resources/        ← Tab4View, AddEquipmentView, AddMaterialView, AddVehicleView, AddToolView, ResourceRowView, EmptyResourcesView
├── Finances/         ← Tab5View (placeholder)
├── Workflow/         ← WorkflowModels, WorkflowService, WorkflowMiniCard, WorkflowViewFactory (stub)
├── Background/       ← AnimatedMeshBackground, MeshScheme, BackgroundState, BackgroundService, BackgroundCoordinator (unused)
├── Navigation/       ← MainTabView, TabRouter, DrawerRouter, DrawerViewFactory, BottomBarView, CustomBottomTabBar, SearchBar, SearchState, BusinessLogo, SettingsButton
└── Settings/         ← SettingsView, BusinessProfile, MemberRowView, MemberDetailView, InviteMemberView
    └── ScopeItemLibrary/ ← ScopeItemLibraryView, ScopeItemTemplateRowView, AddScopeItemTemplateView
```

#### Pattern: Environment Injection from App Root

All shared services are created once at the app entry point and injected via `.environment()`. Features access them with `@Environment`.

```swift
// App/Base1App.swift
@main
struct Base1App: App {
    var body: some Scene {
        WindowGroup {
            RootView(backgroundService: backgroundService)
                .environment(businessManager)
                .environment(tabRouter)
                .environment(drawerRouter)
                .environment(searchState)
                .environment(workflowService)
                .environment(backgroundState)
                .environment(portalService)
                .environment(authService)
                .environment(subscriptionManager)
                .environment(cloudKitSharingService)
        }
        .modelContainer(for: Base1SchemaV1.models)
    }
}
// RootView gates MainTabView behind AuthView based on authService.authState
```

#### Pattern: Offset-Based Tab Navigation

Custom tab switching using offset calculations rather than native `TabView`. Enables full control over transition animations.

```swift
// Features/Navigation/Components/TabRouter.swift
@MainActor @Observable
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

All spacing, sizing, and animation values live in a single `DesignConstants` enum to avoid magic numbers. Card corners use `DesignConstants.Card.cornerRadius` — never hardcode `12`.

```swift
// Shared/Design/DesignConstants.swift
enum DesignConstants {
    enum BottomBar {
        static let cornerRadius: CGFloat = 48
        static let horizontalPadding: CGFloat = 8
    }
    enum Card {
        static let cornerRadius: CGFloat = 12
    }
    enum Animation {
        static let tabSwitchResponse: Double = 0.35
        static let tabSwitchDamping: Double = 0.85
    }
}
```

#### Pattern: DrawerRouter (Centralized Modal Presentation)

All modal content uses a centralized `DrawerRouter` (`@MainActor @Observable` service) instead of `.sheet()`. The `SideDrawer` component slides from the right, occupies the center 1/3 of screen height, and uses `.ultraThinMaterial`. Drawers render as an overlay on `MainTabView` — outside the offset-based tab ZStack — so they always cover the full screen regardless of tab position.

**DrawerRouter** manages a stack of `DrawerDestination` enum values. Views call `drawerRouter.present(.destination)` to open drawers. The stack supports nesting (drawer opens another drawer). `DrawerViewFactory` maps enum cases to SwiftUI views.

**Critical:** `DrawerDestination` associated values use `PersistentIdentifier` (never `@Model` objects directly). `DrawerViewFactory` is a `View` struct that re-fetches models from `@Environment(\.modelContext)` using `modelContext.registeredModel(for:)`.

```swift
// Feature view — present a drawer via the router
@Environment(DrawerRouter.self) private var drawerRouter

// Static destinations
Button { drawerRouter.present(.addClient) }

// Item-based — pass PersistentIdentifier, not the model object
Button { drawerRouter.present(.clientDetail(client.persistentModelID)) }

// Content view — dismiss via environment action
@Environment(\.dismissDrawer) private var dismiss
```

**Why centralized, not per-view:**
- Tab views use offset-based transitions; `.overlay`-based drawers would shift with the tab content
- Nested drawers (e.g., ProjectDetail > AddScopeItem, ProjectDetail > PDFPreview) need full-screen rendering
- Single point of control for all drawer animations, z-ordering, and lifecycle

#### Pattern: Liquid Glass & Morphing UI

Base1 leverages the **Liquid Glass framework (iOS 26+)** for premium, fluid UI elements. This involves using `GlassEffectContainer` to group multiple glass views and enable morphing transitions.

**Key Rules:**
- Only apply `.interactive()` to tappable/focusable elements. Decorative elements use `.regular` only.
- Separate `@Namespace` variables for `glassEffectID` and `matchedGeometryEffect` — never share them.
- Apply `.glassEffect()` **after** all layout and visual modifiers (padding, frame, etc.).
- Never combine `.background(.ultraThinMaterial)` with `GlassEffectContainer` — they conflict.

```swift
GlassEffectContainer(spacing: 8) {
    HStack(spacing: 8) {
        ForEach(options) { option in
            Button { selected = option } label: {
                Text(option.title)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .glassEffect(selected == option ? .regular.interactive() : .clear.interactive(), in: .capsule)
                    .glassEffectID(option.id, in: glassNS)
            }
            .buttonStyle(.plain)
        }
    }
}
```

#### Pattern: Multi-Tenancy via `businessKey`

Every domain model carries a `businessKey` field. All queries and factories accept `businessKey` as a parameter, enabling future multi-business support.

#### Pattern: Date & Number Formatting

Use Swift's `.formatted()` API directly — never allocate `DateFormatter` or `NumberFormatter` instances in view body or computed properties.

```swift
// Dates
date.formatted(date: .medium, time: .omitted)
date.formatted(date: .omitted, time: .shortened)
date.formatted(.dateTime.weekday(.abbreviated))

// Currency (Decimal)
value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
```

---

## Architecture

### Entry Point
- `App/Base1App.swift` — Creates ModelContainer (Base1SchemaV1), initializes all services, injects into environment for MainTabView

### Data Layer (`Shared/Models/`)
All models use `@Model` (SwiftData). Schema defined in `Schema/Base1SchemaV1.swift`.

| File | Type | Purpose |
|------|------|---------|
| `Business.swift` | `Business` | Root entity, owns clients/projects/resources/templates/members/jobTypes/scopeItemTemplates. Fields: businessKey, ownerAppleUserID, name, ownerName, email?, phone?, address?, taxNumber?, logoData?, **contractTerms?**, createdAt |
| `Client.swift` | `Client`, `ClientStatus` | Customer with status (lead/active/closed). Has businessKey. **Portal fields:** portalToken?, portalTokenCreatedAt?, portalEnabled |
| `Project.swift` | `Project`, `ProjectStatus` | Project tracking with budget/timeline. Has businessKey, projectTypeRaw (job type name), scopeItems relationship, assignedMembers many-to-many, measurements, photos, computed totalScopeCost, totalLaborHours, hasInventoryIssues. **Has `isLocked` flag to prevent edits after estimate generation.** **Estimate sharing:** estimateShareToken?, estimateSharedAt?, estimateApprovedAt?, estimateApprovedByName? |
| `Invoice.swift` | `Invoice`, `InvoiceStatus` | Billing (draft/sent/paid/overdue/cancelled). Has businessKey |
| `Appointment.swift` | `Appointment`, `AppointmentType` | Scheduling (consultation/siteVisit/meeting/followUp/delivery). Has businessKey |
| `Resource.swift` | `Resource`, `ResourceCategory` | Equipment/materials/vehicles/tools with category-specific fields. Equipment: equipmentMaterials relationship. Material: materialTypeName, variantLabel, parentMaterial/materialVariants self-referential parent-child. Vehicle: vehicleMake, vehicleModel, startingKilometers, serviceNotes. Tool: assignedVehicle relationship, isShopTool. Common: businessKey, scopeItems relationship, computed allocatedQuantity, availableQuantity, isMaterialType, isMaterialVariant, toolLocationLabel, vehicleDisplayLabel |
| `ScopeItem.swift` | `ScopeItem`, `ScopeItemStatus` | Project scoping line items. Fields: laborHours, description, assignedRole, notes, status (pending/ordered/fulfilled). Has `scopeItemResources` relationship (many resources via `ScopeItemResource`). Computed: estimatedCost. Has businessKey |
| `ScopeItemResource.swift` | `ScopeItemResource` | Join table between `ScopeItem` and `Resource`. Fields: quantity (`Decimal`), unit (`UnitOfMeasure`), businessKey. Relationships: scopeItem, resource |
| `UnitOfMeasure.swift` | `UnitOfMeasure` | Enum of all units (area, length, volume, count, weight, time, etc.) with `abbreviation`, `category`, and `convert(_:to:)` for unit conversion |
| `ProjectMeasurement.swift` | `ProjectMeasurement` | Room/area measurements linked to a project. Fields: businessKey, name, value (`Decimal`), unit (`UnitOfMeasure`), notes?. Relationship: project |
| `ProjectPhoto.swift` | `ProjectPhoto` | Photo attached to a project. Fields: businessKey, imageData (`Data`?), caption?. Relationship: project |
| `Member.swift` | `Member`, `MemberRole`, `InviteStatus` | Team members with roles (owner/admin/member). Fields: businessKey, email, displayName, roleRaw, inviteStatusRaw, **appleUserID?** (linked via Sign in with Apple), **cloudKitShareParticipantID?** (CloudKit share participant), invitedAt, acceptedAt?, createdAt, updatedAt. Relationships: business, assignedProjects (many-to-many with Project). Computed: role, inviteStatus, initials |
| `JobType.swift` | `JobType` | Business-created project types (e.g., Renovation, New Build). Fields: businessKey, name, icon, sortOrder, createdAt. Relationships: business, scopeItemTemplates, children/parent (self-referential hierarchy), templateProject |
| `ScopeItemTemplate.swift` | `ScopeItemTemplate` | Reusable scope item library entries linked to Resources. Fields: businessKey, name, defaultQuantity, defaultLaborHours?, defaultCostMarkup?, notes?, createdAt. Relationships: resource, business, jobType |
| `WorkflowTemplate.swift` | `WorkflowTemplate`, `WorkflowStepTemplate`, `WorkflowCategory` | Reusable workflow blueprints. Has businessKey |
| `ProjectMilestone.swift` | `ProjectMilestone`, `MilestoneType` | Project lifecycle events. **Schedulable types** (siteVisit, materialOrder, workStarted) appear as event blocks on the calendar timeline AND as schedulable rows in ProjectDetailView. **Auto milestones** (created, estimateSent, estimateApproved, workCompleted) appear only as dots on the project line. `isSchedulable` computed property distinguishes them. |
| `SampleData.swift` | Extensions on all models | Preview/test data factories. All factories accept businessKey param |
| `Schema/Base1SchemaV1.swift` | `Base1SchemaV1`, `Base1MigrationPlan` | SwiftData schema versioning |

#### Model Relationships
```
Business 1──* Client, Project, Resource, WorkflowTemplate, Member, JobType, ScopeItemTemplate
Client   1──* Project, Appointment, Invoice, Workflow
Project  *──* Member (assigned team)
Project  1──* ScopeItem 1──* ScopeItemResource *──1 Resource
Project  1──* ProjectMeasurement
Project  1──* ProjectPhoto
Project  1──* Invoice, Appointment, Workflow, ProjectMilestone
WorkflowTemplate 1──* WorkflowStepTemplate
WorkflowTemplate 1──* Workflow (instances)
Workflow 1──* WorkflowStep
Resource(Equipment) *──* Resource(Material) (equipmentMaterials / usedByEquipment)
Resource(Material)  1──* Resource(Material) (parentMaterial / materialVariants, cascade)
Resource(Tool)      *──1 Resource(Vehicle) (assignedVehicle / assignedTools)
JobType  1──* ScopeItemTemplate *──1 Resource
JobType  1──* JobType (parent / children hierarchy)
JobType  0──1 Project (templateProject)
```

### Services (`Shared/Services/`)
| File | Type | Purpose |
|------|------|---------|
| `AuthService.swift` | `AuthService` (`@MainActor @Observable`), `AuthState`, `AppleUserCredentials`, `AuthError` | Sign in with Apple authentication. Keychain storage for credentials. States: `.unknown`, `.signedOut`, `.signedIn(userID:)`. Methods: `checkExistingSession()`, `handleAuthorization(_:)`, `handleAuthorizationError(_:)`, `signOut()`. |
| `SubscriptionManager.swift` | `SubscriptionManager` (`@MainActor @Observable`), `SubscriptionTier`, `SubscriptionStatus`, `SubscriptionError` | StoreKit 2 subscription management. Tiers: none/basic/professional/enterprise with team member limits (0/3/10/unlimited). Methods: `loadProducts()`, `purchase(_:)`, `restorePurchases()`, `canAddTeamMember(currentCount:)`. |
| `CloudKitSharingService.swift` | `CloudKitSharingService` (`@MainActor @Observable`), `PendingShareInvite`, `ParticipantStatus`, `CloudKitSharingError` | CloudKit-based team sharing. Methods: `createBusinessShare(for:invitingMember:)`, `addParticipant(email:to:permission:)`, `acceptShareInvitation(metadata:modelContext:authService:)`, `removeParticipant(member:from:)`. |
| `BusinessManager.swift` | `BusinessManager` (`@MainActor @Observable`) | Business entity CRUD, multi-tenancy, bootstrapping. **Auth integration:** `configureForAuthenticatedUser(appleUserID:credentials:)`, `isBusinessOwner`, `signOut()`. **Role-based access:** `currentMember`, `currentUserRole`, `isOwnerOrAdmin`, `effectiveCurrentMember`. **Debug mode:** `debugModeEnabled`, `debugSelectedMember` for testing role-based views. |
| `ProjectService.swift` | `ProjectService` (`@MainActor` class) | Project template duplication — `duplicateTemplate(from:to:)` copies scope items, measurements, photos. `syncScopeFromParentToVariants(_:)` propagates parent template scope to child job type variants |
| `ClientService.swift` | Free functions | `filteredClients(_:filter:)` — filters `[Client]` by `FilterOption`. No class, no state. |
| `AppointmentService.swift` | Free functions + `ScheduleFilter` | `filteredAppointments(_:filter:)` and `appointmentsGroupedByDay(_:)`. `ScheduleFilter` enum (all/upcoming/past/cancelled) defined here. |
| `PortalService.swift` | `PortalService` (`@MainActor @Observable`) | Client portal magic link generation. Estimate sharing: `generateEstimateLink(for:)`, `getEstimateLink(for:)`, `revokeEstimateLink(for:)`. Client portal: `generateClientPortalLink(for:)`, `getPortalLink(for:)`, `revokePortalAccess(for:)`. Uses `SecRandomCopyBytes` for secure token generation. |

### UI Layer

#### Navigation & Chrome (`Features/Navigation/`)
| File | Type | Purpose |
|------|------|---------|
| `MainTabView.swift` | `MainTabView` | Root view — ZStack with background, tab content (via `GeometryReader` for offset math), drawer overlay, nav buttons |
| `Components/TabRouter.swift` | `TabRouter` (`@MainActor @Observable`) | Tab selection state, offset-based slide animations |
| `Components/DrawerRouter.swift` | `DrawerRouter` (`@MainActor @Observable`), `DrawerDestination` | Centralized drawer presentation — stack-based, supports nesting. `DrawerDestination` uses `PersistentIdentifier` for all model-associated values. |
| `Components/DrawerViewFactory.swift` | `DrawerViewFactory` (`View` struct) | Maps `DrawerDestination` to SwiftUI views. Uses `@Environment(\.modelContext)` + `registeredModel(for:)` to re-fetch models from identifiers. |
| `Components/BottomBarView.swift` | `BottomBarView` | Bottom bar container (search bar, workflow card, tab bar) |
| `Components/CustomBottomTabBar.swift` | `CustomBottomTabBar` | 5-tab bar with matched geometry selection indicator |
| `Components/SearchBar.swift` | `SearchBar` | Search input with auto-focus |
| `Components/SearchState.swift` | `SearchState` (`@MainActor @Observable`) | Search text and active state |
| `Components/BusinessLogo.swift` | `BusinessLogo` | Top-left profile button |
| `Components/SettingsButton.swift` | `SettingsButton` | Top-right settings button |

#### Workflow System (`Features/Workflow/`)
| File | Type | Purpose |
|------|------|---------|
| `WorkflowModels.swift` | `Workflow`, `WorkflowStep` (`@Model`) | Runtime workflow instances (SwiftData) |
| `WorkflowService.swift` | `WorkflowService` (`@MainActor @Observable`) | Workflow lifecycle (start/pause/skip/complete) |
| `WorkflowMiniCard.swift` | `WorkflowMiniCard`, `WorkflowProgressBar` | Compact workflow display in bottom bar |
| `WorkflowViewFactory.swift` | `WorkflowViewFactory` | Maps step viewKey strings to SwiftUI views (stub) |

#### Auth System (`Features/Auth/`)
| File | Type | Purpose |
|------|------|---------|
| `AuthView.swift` | `AuthView` | Sign in with Apple UI — app branding, feature preview rows, `SignInWithAppleButton`, error display, loading overlay. Gates app access via `RootView`. |
| `SubscriptionView.swift` | `SubscriptionView`, `TierCard` | Subscription management — current status, billing toggle (monthly/yearly), tier cards with features, purchase button, restore purchases. Presented as sheet from SettingsView. |

#### Feature Views
| File | Type | Feature | Purpose |
|------|------|---------|---------|
| `Features/Clients/Tab1View.swift` | `Tab1View` | Clients | Client list with filter picker + add client side drawer. Uses `filteredClients(_:filter:)` free function. |
| `Features/Clients/AddClientView.swift` | `AddClientView` | Clients | Add client form |
| `Features/Clients/ClientRowView.swift` | `ClientRowView` | Clients | Client list row — tappable via `Button` → `.clientDetail` drawer |
| `Features/Clients/ClientDetailView.swift` | `ClientDetailView` | Clients | Client detail drawer — contact info, linked projects, appointments. Uses `sortedProjects` and `sortedAppointments` computed properties. |
| `Features/Clients/EmptyClientsView.swift` | `EmptyClientsView` | Clients | Empty state |
| `Features/Schedule/Tab2View.swift` | `Tab2View` | Schedule | Calendar day view with date selector, all-day banner, DayTimelineView + add appointment side drawer. Empty state only shown when no appointments AND no active projects. |
| `Features/Schedule/DayTimelineView.swift` | `DayTimelineView` | Schedule | Apple Calendar-style day timeline — hour grid, vertical project lines with milestone dots, positioned event blocks (appointments + schedulable milestones), unified overlap layout, now-line. Uses `GeometryReader` for pixel-accurate event layout. |
| `Features/Schedule/AddAppointmentView.swift` | `AddAppointmentView` | Schedule | Add appointment form — type, date/time, all-day, location, client/project linking, reminders |
| `Features/Schedule/AddScheduleView.swift` | `AddScheduleView` | Schedule | Schedule a milestone event — horizontal member picker scroll, date/time, duration |
| `Features/Schedule/AppointmentRowView.swift` | `AppointmentRowView` | Schedule | Appointment list row — type icon, time, client, location, status indicators |
| `Features/Schedule/EmptyScheduleView.swift` | `EmptyScheduleView` | Schedule | Empty state |
| `Features/Projects/Tab3View.swift` | `Tab3View` | Projects | Project list with status filter picker (LiquidGlassFilterPicker) + add project side drawer. **Role-based filtering:** non-admin members see only assigned projects via `visibleProjects` computed property. |
| `Features/Projects/AddProjectView.swift` | `AddProjectView` | Projects | Add project form — client first, job type picker, auto-title, budget, start/due dates, team member assignment, description. Status auto-set to planning, scope items pre-filled from template. Uses `sortedParentJobTypeChildren` computed property. |
| `Features/Projects/ProjectRowView.swift` | `ProjectRowView` | Projects | Project list row — tappable via `Button` → `.projectDetail` drawer. Status badge, job type label, client name, date range, overdue indicator, estimate button. |
| `Features/Projects/EmptyProjectsView.swift` | `EmptyProjectsView` | Projects | Empty state |
| `Features/Projects/ProjectDetailView.swift` | `ProjectDetailView` | Projects | Project detail side drawer — header, schedule section, scope items list, measurements, photos, summary cards (cost, labor, inventory warnings). Uses `sortedScopeItems`, `sortedMeasurements`, `sortedPhotos` computed properties. **Inline forms:** uses `ExpandableCard` for adding measurements and photos instead of nested drawers. **Project notes editor** for contract terms. **Staff permissions:** `canAddPhotos` allows assigned staff to add progress photos on in-progress projects. |
| `Features/Projects/AddScopeItemView.swift` | `AddScopeItemView` | Projects | Add scope item form — resource picker with multi-resource support (`ScopeItemResource` join), quantity per resource, unit of measure, measurement chip selector (horizontal scroll), labor hours, live cost estimate. **Template picker:** select from `ScopeItemTemplate` to pre-fill form via `applyTemplate(_:)`. |
| `Features/Projects/AddMeasurementView.swift` | `AddMeasurementView` | Projects | Add measurement form — name, value, unit picker |
| `Features/Projects/AddProjectPhotoView.swift` | `AddProjectPhotoView` | Projects | Add photo form — PhotosPicker integration, caption |
| `Features/Projects/ProjectEstimatePDFView.swift` | `ProjectEstimatePDFView` | Projects | Letter-formatted (8.5" × 11" = 612×792pt) estimate view for PDF generation. Uses static font sizes and `Color` values (not adaptive). **Footer sections:** Item Notes (scope item notes), Project Notes (project.notes), Terms & Conditions (business.contractTerms). |
| `Features/Projects/PDFPreviewView.swift` | `PDFPreviewView` | Projects | PDF generation and preview drawer — `ImageRenderer` snapshot on `@MainActor`, `CGContext` PDF file written via `Task.detached`, displayed via `PDFKit.PDFView`. Share PDF via `ShareLink`. **Share Link button** opens `ShareEstimateView` for magic link sharing. |
| `Features/Projects/ShareEstimateView.swift` | `ShareEstimateView` | Projects | Magic link sharing UI — generates/displays estimate share link via `PortalService`, copy to clipboard, share sheet, revoke link. |
| `Features/Projects/ScopeItemRowView.swift` | `ScopeItemRowView` | Projects | Scope item row — resource icons, quantity, cost, status badge, inventory shortfall warning. **Staff action:** "Mark Complete" button for assigned member via `showMarkCompleteAction` computed property. |
| `Features/Resources/Tab4View.swift` | `Tab4View`, `ResourceListSheet` | Resources | 2x2 category grid (Equipment/Materials/Vehicles/Tools) — each card has Add and Open buttons. ResourceListSheet shows filtered list per category |
| `Features/Resources/AddEquipmentView.swift` | `AddEquipmentView` | Resources | Add equipment form |
| `Features/Resources/AddMaterialView.swift` | `AddMaterialView` | Resources | Add material form — "New Type" or "Add Variant" modes |
| `Features/Resources/AddVehicleView.swift` | `AddVehicleView` | Resources | Add vehicle form |
| `Features/Resources/AddToolView.swift` | `AddToolView` | Resources | Add tool form |
| `Features/Resources/ResourceRowView.swift` | `ResourceRowView` | Resources | Resource list row — category-specific detail |
| `Features/Resources/EmptyResourcesView.swift` | `EmptyResourcesView` | Resources | Empty state |
| `Features/Finances/Tab5View.swift` | `Tab5View` | Finances | Finances tab (placeholder) |
| `Features/Settings/SettingsView.swift` | `SettingsView` | Settings | Settings screen — account section (user info, subscription link, sign out), **debug role switcher** (#if DEBUG) for testing role-based views without multiple iCloud accounts. Uses `debugModeEnabled` and `debugSelectedMember` from BusinessManager. |
| `Features/Settings/BusinessProfile.swift` | `BusinessProfile` | Settings | Business info editing — inline fields, PhotosPicker logo, team management section, job types & templates link. **Contract terms editor** for business-wide estimate terms. **Scope Item Library navigation** button. |
| `Features/Settings/ScopeItemLibrary/ScopeItemLibraryView.swift` | `ScopeItemLibraryView` | Settings | Scope item template library — list all templates with JobType filter picker, add/edit/delete templates. Uses `selectedJobType` and `showAllJobTypes` for filtering. |
| `Features/Settings/ScopeItemLibrary/ScopeItemTemplateRowView.swift` | `ScopeItemTemplateRowView` | Settings | Template list row — resource icon, name, job type, default values. Tap to edit, context menu to delete. |
| `Features/Settings/ScopeItemLibrary/AddScopeItemTemplateView.swift` | `AddScopeItemTemplateView` | Settings | Add/edit template form — name, job type picker, resource picker, default quantity/unit/labor hours/notes. |
| `Features/Settings/MemberRowView.swift` | `MemberRowView` | Settings | Team member list row — avatar initials, name, email, role badge, invite status. Tappable via `Button` → `.memberDetail` drawer. |
| `Features/Settings/MemberDetailView.swift` | `MemberDetailView` | Settings | Member detail drawer — role, invite status, assigned projects with milestone timeline. Uses `sortedMilestoneProjects` and `sortedMilestones(for:)` computed helpers. |
| `Features/Settings/InviteMemberView.swift` | `InviteMemberView` | Settings | Invite member form side drawer — email, display name, role picker (admin/member). **CloudKit sharing integration:** creates share via `CloudKitSharingService`, displays share link, team limit warning based on subscription tier. Includes `ShareSheet` UIViewControllerRepresentable. |

#### Shared Components (`Shared/UI/Components/`)
| File | Type | Purpose |
|------|------|---------|
| `LabeledTextField.swift` | `LabeledTextField` | Shared labeled text field with icon + keyboard type |
| `BindingExtensions.swift` | `Binding<String?>.orEmpty` | Optional string binding helper |
| `DrawerHeader.swift` | `DrawerHeader` | Reusable header component for drawer views — title, optional subtitle, dismiss button |
| `ExpandableCard.swift` | `ExpandableCard<Header, Content>` | Generic expandable card with collapsed/expanded states. Spring animation using `DesignConstants.Animation.morphResponse/morphDamping`. `.thinMaterial` background. Replaces nested drawer pattern for inline forms. `onExpand`/`onCollapse` callbacks. |
| `LiquidGlassFilterPicker.swift` | `LiquidGlassFilterPicker<Filter: Filterable>`, `Filterable` protocol, `FilterOption` (Clients), `ProjectFilterOption` (Projects) | Generic glass morphism segmented control. Uses separate `@Namespace` for `glassEffectID` vs `matchedGeometryEffect` to avoid conflicts. |
| `SideDrawer.swift` | `SideDrawer<Content>`, `DrawerDismissAction`, `NavigationBackgroundCleaner` | Side drawer rendering component — slides from right, center 1/3 height, ultraThinMaterial, dimmed backdrop. Content views use `@Environment(\.dismissDrawer)` to dismiss. |

#### Design System (`Shared/Design/`)
| File | Type | Purpose |
|------|------|---------|
| `DesignConstants.swift` | `DesignConstants` | Centralized spacing/sizing/animation constants. Includes `Card.cornerRadius = 12` — use everywhere instead of hardcoded `12`. |

#### Background Animation (`Features/Background/`)
| File | Type | Purpose |
|------|------|---------|
| `AnimatedMeshBackground.swift` | `AnimatedMeshBackground` | 3x3 MeshGradient with animated center point |
| `Components/MeshScheme.swift` | `MeshScheme` | Color scheme enum (gold/amber/blue/crimson/mint/violet/teal) |
| `Components/BackgroundState.swift` | `BackgroundState` (`@MainActor @Observable`) | Current scheme + transition progress |
| `Components/BackgroundService.swift` | `BackgroundService` | Pure value mapper — maps tab index to `MeshScheme`. No state, no `@MainActor`. |
| `Components/BackgroundCoordinator.swift` | `BackgroundCoordinator` (`@MainActor @Observable`) | Transition coordination (currently unused) |

### Tab Mapping
| Index | Tab | View | Background | Color |
|-------|-----|------|------------|-------|
| 0 | Clients | Tab1View | gold | Gold |
| 1 | Schedule | Tab2View | amber | Amber |
| 2 | Projects | Tab3View | blue | Blue |
| 3 | Resources | Tab4View | crimson | Crimson |
| 4 | Finances | Tab5View | mint | Mint |
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
│   │   ├── ScopeItemResource.swift
│   │   ├── UnitOfMeasure.swift
│   │   ├── ProjectMeasurement.swift
│   │   ├── ProjectPhoto.swift
│   │   ├── Member.swift
│   │   ├── JobType.swift
│   │   ├── ScopeItemTemplate.swift
│   │   ├── WorkflowTemplate.swift
│   │   ├── ProjectMilestone.swift
│   │   ├── SampleData.swift
│   │   └── Schema/
│   │       └── Base1SchemaV1.swift
│   ├── Services/
│   │   ├── AuthService.swift
│   │   ├── SubscriptionManager.swift
│   │   ├── CloudKitSharingService.swift
│   │   ├── BusinessManager.swift
│   │   ├── ProjectService.swift
│   │   ├── ClientService.swift
│   │   ├── AppointmentService.swift
│   │   └── PortalService.swift
│   ├── Design/
│   │   └── DesignConstants.swift
│   └── UI/
│       └── Components/
│           ├── DrawerHeader.swift
│           ├── LabeledTextField.swift
│           ├── BindingExtensions.swift
│           ├── ExpandableCard.swift
│           ├── LiquidGlassFilterPicker.swift
│           └── SideDrawer.swift
└── Features/
    ├── Auth/
    │   ├── AuthView.swift
    │   └── SubscriptionView.swift
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
    │   ├── AddScheduleView.swift
    │   ├── AppointmentRowView.swift
    │   ├── DayTimelineView.swift
    │   └── EmptyScheduleView.swift
    ├── Projects/
    │   ├── Tab3View.swift
    │   ├── AddProjectView.swift
    │   ├── AddMeasurementView.swift
    │   ├── AddProjectPhotoView.swift
    │   ├── AddScopeItemView.swift
    │   ├── EmptyProjectsView.swift
    │   ├── PDFPreviewView.swift
    │   ├── ProjectDetailView.swift
    │   ├── ProjectEstimatePDFView.swift
    │   ├── ProjectRowView.swift
    │   ├── ScopeItemRowView.swift
    │   └── ShareEstimateView.swift
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
        ├── MemberDetailView.swift
        ├── InviteMemberView.swift
        └── ScopeItemLibrary/
            ├── ScopeItemLibraryView.swift
            ├── ScopeItemTemplateRowView.swift
            └── AddScopeItemTemplateView.swift
```
