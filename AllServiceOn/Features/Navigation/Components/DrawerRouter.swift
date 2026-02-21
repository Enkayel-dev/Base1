//
//  DrawerRouter.swift
//  Base1
//

import SwiftUI
import SwiftData

// MARK: - Drawer Destination

enum DrawerDestination: Identifiable, Equatable {

    // Clients
    case addClient
    case clientDetail(PersistentIdentifier)
    case memberDetail(PersistentIdentifier)

    // Schedule
    case addAppointment

    // Projects
    case addProject
    case projectDetail(PersistentIdentifier)
    case addScopeItem(PersistentIdentifier)
    case addMeasurement(PersistentIdentifier)
    case addProjectPhoto(PersistentIdentifier)
    case projectEstimate(PersistentIdentifier)
    case addSchedule(PersistentIdentifier, MilestoneType)

    // Resources
    case addEquipment
    case addMaterial
    case addVehicle
    case addTool
    case equipmentList
    case materialList
    case vehicleList
    case toolList
    case materialVariants(PersistentIdentifier)

    // Settings / Business
    case inviteMember
    case scopeItemLibrary
    case addScopeItemTemplate
    case editScopeItemTemplate(PersistentIdentifier)
    
    // Sharing
    case shareEstimate(PersistentIdentifier)

    // MARK: Identifiable

    var id: String {
        switch self {
        case .addClient:                        "addClient"
        case .clientDetail(let id):             "clientDetail-\(id.hashValue)"
        case .memberDetail(let id):             "memberDetail-\(id.hashValue)"
        case .addAppointment:                   "addAppointment"
        case .addProject:                       "addProject"
        case .projectDetail(let id):            "projectDetail-\(id.hashValue)"
        case .addScopeItem(let id):             "addScopeItem-\(id.hashValue)"
        case .addMeasurement(let id):           "addMeasurement-\(id.hashValue)"
        case .addProjectPhoto(let id):          "addProjectPhoto-\(id.hashValue)"
        case .projectEstimate(let id):          "projectEstimate-\(id.hashValue)"
        case .addSchedule(let id, let m):       "addSchedule-\(id.hashValue)-\(m.rawValue)"
        case .addEquipment:                     "addEquipment"
        case .addMaterial:                      "addMaterial"
        case .addVehicle:                       "addVehicle"
        case .addTool:                          "addTool"
        case .equipmentList:                    "equipmentList"
        case .materialList:                     "materialList"
        case .vehicleList:                      "vehicleList"
        case .toolList:                         "toolList"
        case .materialVariants(let id):         "materialVariants-\(id.hashValue)"
        case .inviteMember:                     "inviteMember"
        case .scopeItemLibrary:                 "scopeItemLibrary"
        case .addScopeItemTemplate:             "addScopeItemTemplate"
        case .editScopeItemTemplate(let id):    "editScopeItemTemplate-\(id.hashValue)"
        case .shareEstimate(let id):            "shareEstimate-\(id.hashValue)"
        }
    }

    // MARK: Equatable

    static func == (lhs: DrawerDestination, rhs: DrawerDestination) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - DrawerRouter

@MainActor @Observable
final class DrawerRouter {

    private(set) var drawerStack: [DrawerDestination] = []

    var currentDrawer: DrawerDestination? { drawerStack.last }
    var isPresented: Bool { !drawerStack.isEmpty }

    func present(_ destination: DrawerDestination) {
        drawerStack.append(destination)
    }

    func dismiss() {
        guard !drawerStack.isEmpty else { return }
        drawerStack.removeLast()
    }

    func dismissAll() {
        drawerStack.removeAll()
    }
}
