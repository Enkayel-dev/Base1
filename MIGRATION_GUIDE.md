# Base1 — File Structure Migration Guide
> **Milestone**: Phase 1 Complete → Phase 2 Feature-Centric Architecture  
> **Date**: February 2026

---

## Current Index (As-Is)

```
Base1/
├── Base1App.swift
├── ContentView.swift
├── Assets.xcassets/
├── Models/
│   ├── Appointment.swift
│   ├── Business.swift
│   ├── Client.swift
│   ├── Invoice.swift
│   ├── Project.swift
│   ├── Resource.swift
│   ├── SampleData.swift
│   ├── WorkflowTemplate.swift
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
    ├── AddClientView.swift
    ├── Components/
    │   ├── LabeledTextField.swift
    │   ├── BindingExtensions.swift
    │   └── LiquidGlassFilterPicker.swift
    ├── RowViews/
    │   └── ClientRowView.swift
    └── EmptyViews/
        └── EmptyClientsView.swift
```

---

## Planned Index (To-Be)

```
Base1/
├── Assets.xcassets/
│
├── App/
│   ├── Base1App.swift
│   └── ContentView.swift
│
├── Shared/
│   ├── Models/
│   │   ├── Appointment.swift
│   │   ├── Business.swift
│   │   ├── Client.swift
│   │   ├── Invoice.swift
│   │   ├── Project.swift
│   │   ├── Resource.swift
│   │   ├── SampleData.swift
│   │   ├── WorkflowTemplate.swift
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
│
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
    │   ├── ClientsView.swift          ← was Tab1View.swift
    │   ├── AddClientView.swift
    │   ├── ClientRowView.swift        ← was RowViews/ClientRowView.swift
    │   └── EmptyClientsView.swift     ← was EmptyViews/EmptyClientsView.swift
    ├── Schedule/
    │   └── ScheduleView.swift         ← was Tab2View.swift
    ├── Projects/
    │   └── ProjectsView.swift         ← was Tab3View.swift
    ├── Resources/
    │   └── ResourcesView.swift        ← was Tab4View.swift
    ├── Finances/
    │   └── FinancesView.swift         ← was Tab5View.swift
    └── Settings/
        ├── SettingsView.swift
        └── BusinessProfile.swift
```

---

## Move + Rename Checklist

Use this checklist to track your progress. Items marked **★ RENAME** require both a file rename and a `struct` rename inside the file.

### App
- [ ] Create `App/` folder
- [ ] Move `Base1App.swift` → `App/`
- [ ] Move `ContentView.swift` → `App/`

### Shared / Models
- [ ] Create `Shared/Models/` folder (with `Schema/` subfolder)
- [ ] Move all `Models/*` → `Shared/Models/`

### Shared / Services
- [ ] Create `Shared/Services/` folder
- [ ] Move all `Services/*` → `Shared/Services/`

### Shared / Design
- [ ] Create `Shared/Design/` folder
- [ ] Move `Overlay/Components/DesignConstants.swift` → `Shared/Design/`

### Shared / UI / Components
- [ ] Create `Shared/UI/Components/` folder
- [ ] Move `Views/Components/LabeledTextField.swift` → `Shared/UI/Components/`
- [ ] Move `Views/Components/BindingExtensions.swift` → `Shared/UI/Components/`
- [ ] Move `Views/Components/LiquidGlassFilterPicker.swift` → `Shared/UI/Components/`

### Features / Navigation
- [ ] Create `Features/Navigation/Components/` folder
- [ ] Move `Overlay/MainTabView.swift` → `Features/Navigation/`
- [ ] Move remaining `Overlay/Components/*` → `Features/Navigation/Components/`
  - BottomBarView, BusinessLogo, CustomBottomTabBar, SearchBar, SearchState, SettingsButton, TabRouter

### Features / Workflow
- [ ] Create `Features/Workflow/` folder
- [ ] Move all `Overlay/Workflow/*` → `Features/Workflow/`

### Features / Background
- [ ] Create `Features/Background/Components/` folder
- [ ] Move all `Background/*` → `Features/Background/`

### Features / Clients ★ RENAME
- [ ] Create `Features/Clients/` folder
- [ ] Move `Views/Tab1View.swift` → `Features/Clients/ClientsView.swift`
- [ ] **Rename struct** `Tab1View` → `ClientsView` inside the file
- [ ] Move `Views/AddClientView.swift` → `Features/Clients/`
- [ ] Move `Views/RowViews/ClientRowView.swift` → `Features/Clients/`
- [ ] Move `Views/EmptyViews/EmptyClientsView.swift` → `Features/Clients/`

### Features / Schedule ★ RENAME
- [ ] Create `Features/Schedule/` folder
- [ ] Move `Views/Tab2View.swift` → `Features/Schedule/ScheduleView.swift`
- [ ] **Rename struct** `Tab2View` → `ScheduleView` inside the file

### Features / Projects ★ RENAME
- [ ] Create `Features/Projects/` folder
- [ ] Move `Views/Tab3View.swift` → `Features/Projects/ProjectsView.swift`
- [ ] **Rename struct** `Tab3View` → `ProjectsView` inside the file

### Features / Resources ★ RENAME
- [ ] Create `Features/Resources/` folder
- [ ] Move `Views/Tab4View.swift` → `Features/Resources/ResourcesView.swift`
- [ ] **Rename struct** `Tab4View` → `ResourcesView` inside the file

### Features / Finances ★ RENAME
- [ ] Create `Features/Finances/` folder
- [ ] Move `Views/Tab5View.swift` → `Features/Finances/FinancesView.swift`
- [ ] **Rename struct** `Tab5View` → `FinancesView` inside the file

### Features / Settings
- [ ] Create `Features/Settings/` folder
- [ ] Move `Views/SettingsView.swift` → `Features/Settings/`
- [ ] Move `Views/BusinessProfile.swift` → `Features/Settings/`

### Cleanup
- [ ] Delete empty `Models/`, `Services/`, `Views/`, `Overlay/`, `Background/` folders

---

## Code References to Update After Renames

The following file references the old `Tab*View` struct names and **must be updated**:

### `MainTabView.swift` (now in `Features/Navigation/`)

Update the `TabContentView` body (around lines 97–115):

```diff
-Tab1View()
+ClientsView()

-Tab2View()
+ScheduleView()

-Tab3View()
+ProjectsView()

-Tab4View()
+ResourcesView()

-Tab5View()
+FinancesView()
```

### `SettingsView.swift` (now in `Features/Settings/`)

Line 16 has a comment referencing `Tab1View`:
```diff
-// Centered title matching Tab1View style
+// Centered title matching feature view style
```

No other files reference the `Tab*View` struct names.

---

## Xcode Step-by-Step Transition

After completing all file moves on disk:

1. **Open** `Base1.xcodeproj` in Xcode 26.2
2. In the **Project Navigator** (⌘1), you'll see red/missing file references under the old groups (`Models`, `Views`, `Overlay`, `Background`, `Services`)
3. **Select all red references** → Right-click → **Delete** → Choose **"Remove Reference"** (NOT "Move to Trash")
4. **Right-click** the `Base1` group (yellow folder icon at the top) → **Add Files to "Base1"…**
5. Select the three new top-level folders from Finder:
   - `App`
   - `Shared`
   - `Features`
6. Ensure **"Create groups"** is selected (not "Create folder references")
7. Ensure **"Add to targets: Base1"** is checked
8. Click **Add**
9. **Verify Build Settings**: Go to project settings → Build Settings → Search for `Info.plist` → Confirm the path is still correct (should be `Base1/Info.plist` — unchanged)
10. **Build** (⌘B) to verify everything compiles
11. If any file shows as missing, use **File → Add Files to "Base1"…** to re-add it individually
12. **Delete** the now-empty old folders from disk if they still exist (`Models/`, `Services/`, `Views/`, `Overlay/`, `Background/`)
