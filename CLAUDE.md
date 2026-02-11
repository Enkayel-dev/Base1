# Base1 - Business Management iOS App

## Project Overview
SwiftUI + SwiftData business management app with animated mesh gradient backgrounds, glass morphism UI, tab-based navigation, and a workflow engine. Targets iOS with multi-tenancy support.

## Critical Rules
- **NEVER create new files without first confirming existing files.** Use `find` or `ls` to verify a file doesn't already exist before creating one.
- **NEVER duplicate models, services, or views.** All types are defined once. Check this index before writing.
- **NEVER move files between folders** without explicit user instruction.
- **Read before writing.** Always read a file's current contents before modifying it.
- **Preserve the architecture.** Models go in `Models/`, Services in `Services/`, Views in `Views/`, UI chrome in `Overlay/`.

## Build & Run
- **Platform:** iOS (SwiftUI, SwiftData)
- **Xcode project:** `Base1.xcodeproj`
- **Build:** `xcodebuild -project Base1.xcodeproj -scheme Base1 -destination 'platform=iOS Simulator,name=iPhone 16' build`
- **No package manager dependencies** — pure Apple frameworks

## Architecture

### Entry Point
- `Base1App.swift` — Creates ModelContainer (Base1SchemaV1), initializes all services, injects into environment for MainTabView

### Data Layer (`Models/`)
All models use `@Model` (SwiftData). Schema defined in `Schema/Base1SchemaV1.swift`.

| File | Type | Purpose |
|------|------|---------|
| `Business.swift` | `Business` | Root entity, owns clients/projects/resources/templates |
| `Client.swift` | `Client`, `ClientStatus` | Customer with status (lead/active/closed) |
| `Project.swift` | `Project`, `ProjectStatus`, `ProjectPriority` | Project tracking with budget/timeline |
| `Invoice.swift` | `Invoice`, `InvoiceStatus` | Billing (draft/sent/paid/overdue/cancelled) |
| `Appointment.swift` | `Appointment`, `AppointmentType` | Scheduling (consultation/siteVisit/meeting/followUp/delivery) |
| `Resource.swift` | `Resource`, `ResourceCategory` | Equipment/materials/vehicles/tools |
| `WorkflowTemplate.swift` | `WorkflowTemplate`, `WorkflowStepTemplate`, `WorkflowCategory` | Reusable workflow blueprints |
| `SampleData.swift` | Extensions on all models | Preview/test data factories |
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

### Services (`Services/`)
| File | Type | Purpose |
|------|------|---------|
| `BusinessManager.swift` | `BusinessManager` (@Observable) | Business entity CRUD, multi-tenancy, bootstrapping |
| `ClientService.swift` | `ClientService` (@Observable) | Client filtering by status |

### UI Layer

#### Navigation & Chrome (`Overlay/`)
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
| `Components/DesignConstants.swift` | `DesignConstants` | Centralized spacing/sizing/animation constants |

#### Workflow System (`Overlay/Workflow/`)
| File | Type | Purpose |
|------|------|---------|
| `WorkflowModels.swift` | `Workflow`, `WorkflowStep` (@Model) | Runtime workflow instances (SwiftData) |
| `WorkflowService.swift` | `WorkflowService` (@Observable) | Workflow lifecycle (start/pause/skip/complete) |
| `WorkflowMiniCard.swift` | `WorkflowMiniCard`, `WorkflowProgressBar` | Compact workflow display in bottom bar |
| `WorkflowViewFactory.swift` | `WorkflowViewFactory` | Maps step viewKey strings to SwiftUI views (stub) |

#### Views (`Views/`)
| File | Type | Purpose |
|------|------|---------|
| `Tab1View.swift` | `Tab1View` | Clients tab — filter picker + client list (implemented) |
| `Tab2View.swift` | `Tab2View` | Schedule tab (placeholder) |
| `Tab3View.swift` | `Tab3View` | Projects tab (placeholder) |
| `Tab4View.swift` | `Tab4View` | Resources tab (placeholder) |
| `Tab5View.swift` | `Tab5View` | Finances tab (placeholder) |
| `SettingsView.swift` | `SettingsView` | Settings screen (mock) |
| `BusinessProfile.swift` | `BusinessProfile` | Business info display |
| `Components/LiquidGlassFilterPicker.swift` | `LiquidGlassFilterPicker`, `FilterOption` | Glass morphism segmented control |
| `RowViews/ClientRowView.swift` | `ClientRowView` | Client list row |
| `EmptyViews/EmptyClientsView.swift` | `EmptyClientsView` | Empty state for clients |

#### Background Animation (`Background/`)
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
| 0 | Clients | Tab1View | gold | Gold |
| 1 | Schedule | Tab2View | amber | Amber |
| 2 | Projects | Tab3View | blue | Blue |
| 3 | Resources | Tab4View | crimson | Crimson |
| 4 | Finances | Tab5View | mint | Mint |
| — | Settings | SettingsView | violet | Violet |
| — | Profile | BusinessProfile | teal | Teal |

### Key Patterns
- **@Observable** for all services/state (not ObservableObject)
- **Environment injection** from Base1App into MainTabView
- **Offset-based tab switching** (not native TabView)
- **Matched geometry effects** for animated selection indicators
- **Glass morphism** via `.glassEffect()` / `GlassEffectContainer` modifiers
- **Multi-tenancy** via `businessKey` on Business and Client models

## Directory Structure
```
Base1/
├── Base1App.swift              # App entry point
├── ContentView.swift           # Preview wrapper
├── Assets.xcassets/            # Colors (Accent, Gold, Color)
├── Models/
│   ├── Business.swift
│   ├── Client.swift
│   ├── Project.swift
│   ├── Invoice.swift
│   ├── Appointment.swift
│   ├── Resource.swift
│   ├── WorkflowTemplate.swift
│   ├── SampleData.swift
│   └── Schema/
│       └── Base1SchemaV1.swift
├── Services/
│   ├── BusinessManager.swift
│   └── ClientService.swift
├── Overlay/
│   ├── MainTabView.swift
│   ├── Components/
│   │   ├── BottomBarView.swift
│   │   ├── BusinessLogo.swift
│   │   ├── CustomBottomTabBar.swift
│   │   ├── DesignConstants.swift
│   │   ├── SearchBar.swift
│   │   ├── SearchState.swift
│   │   ├── SettingsButton.swift
│   │   └── TabRouter.swift
│   └── Workflow/
│       ├── WorkflowMiniCard.swift
│       ├── WorkflowModels.swift
│       ├── WorkflowService.swift
│       └── WorkflowViewFactory.swift
├── Background/
│   ├── AnimatedMeshBackground.swift
│   └── Components/
│       ├── BackgroundCoordinator.swift
│       ├── BackgroundService.swift
│       ├── BackgroundState.swift
│       └── MeshScheme.swift
└── Views/
    ├── Tab1View.swift
    ├── Tab2View.swift
    ├── Tab3View.swift
    ├── Tab4View.swift
    ├── Tab5View.swift
    ├── SettingsView.swift
    ├── BusinessProfile.swift
    ├── Components/
    │   └── LiquidGlassFilterPicker.swift
    ├── RowViews/
    │   └── ClientRowView.swift
    └── EmptyViews/
        └── EmptyClientsView.swift
```
