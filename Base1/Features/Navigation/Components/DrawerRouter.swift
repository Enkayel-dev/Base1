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

    // Schedule
    case addAppointment

    // Projects
    case addProject
    case projectDetail(Project)
    case addScopeItem(Project)

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
    case jobTypeList
    case addJobType
    case jobTypeDetail(JobType)
    case addScopeItemTemplate(JobType)

    // MARK: Identifiable

    var id: String {
        switch self {
        case .addClient:                        "addClient"
        case .clientDetail(let c):              "clientDetail-\(c.id)"
        case .addAppointment:                   "addAppointment"
        case .addProject:                       "addProject"
        case .projectDetail(let p):             "projectDetail-\(p.id)"
        case .addScopeItem(let p):              "addScopeItem-\(p.id)"
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
        case .jobTypeList:                      "jobTypeList"
        case .addJobType:                       "addJobType"
        case .jobTypeDetail(let j):             "jobTypeDetail-\(j.id)"
        case .addScopeItemTemplate(let j):      "addScopeItemTemplate-\(j.id)"
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
