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
    case clientDetail(Client)
    case memberDetail(Member)

    // Schedule
    case addAppointment

    // Projects
    case addProject
    case projectDetail(Project)
    case addScopeItem(Project)
    case addMeasurement(Project)
    case addProjectPhoto(Project)
    case projectEstimate(Project)
    case addSchedule(Project, MilestoneType)

    // Resources
    case addEquipment
    case addMaterial
    case addVehicle
    case addTool
    case equipmentList
    case materialList
    case vehicleList
    case toolList
    case materialVariants(Resource)

    // Settings / Business
    case inviteMember

    // MARK: Identifiable

    var id: String {
        switch self {
        case .addClient:                        "addClient"
        case .clientDetail(let c):              "clientDetail-\(c.id)"
        case .memberDetail(let m):              "memberDetail-\(m.id)"
        case .addAppointment:                   "addAppointment"
        case .addProject:                       "addProject"
        case .projectDetail(let p):             "projectDetail-\(p.id)"
        case .addScopeItem(let p):              "addScopeItem-\(p.id)"
        case .addMeasurement(let p):            "addMeasurement-\(p.id)"
        case .addProjectPhoto(let p):           "addProjectPhoto-\(p.id)"
        case .projectEstimate(let p):           "projectEstimate-\(p.id)"
        case .addSchedule(let p, let m):        "addSchedule-\(p.id)-\(m.rawValue)"
        case .addEquipment:                     "addEquipment"
        case .addMaterial:                      "addMaterial"
        case .addVehicle:                       "addVehicle"
        case .addTool:                          "addTool"
        case .equipmentList:                    "equipmentList"
        case .materialList:                     "materialList"
        case .vehicleList:                      "vehicleList"
        case .toolList:                         "toolList"
        case .materialVariants(let r):          "materialVariants-\(r.id)"
        case .inviteMember:                     "inviteMember"
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
