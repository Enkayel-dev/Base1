//
//  DrawerViewFactory.swift
//  Base1
//

import SwiftUI

enum DrawerViewFactory {

    @MainActor @ViewBuilder
    static func view(for destination: DrawerDestination) -> some View {
        switch destination {

        // Clients
        case .addClient:
            AddClientView()
        case .clientDetail(let client):
            ClientDetailView(client: client)

        // Schedule
        case .addAppointment:
            AddAppointmentView()

        // Projects
        case .addProject:
            AddProjectView()
        case .projectDetail(let project):
            ProjectDetailView(project: project)
        case .addScopeItem(let project):
            AddScopeItemView(project: project)

        // Resources
        case .addEquipment:
            AddEquipmentView()
        case .addMaterial:
            AddMaterialView()
        case .addVehicle:
            AddVehicleView()
        case .addTool:
            AddToolView()
        case .equipmentList:
            ResourceListSheet(category: .equipment)
        case .materialList:
            ResourceListSheet(category: .material)
        case .vehicleList:
            ResourceListSheet(category: .vehicle)
        case .toolList:
            ResourceListSheet(category: .tool)
        case .materialVariants(let resource):
            MaterialVariantsSheet(materialType: resource)

        // Settings / Business
        case .inviteMember:
            InviteMemberView()
        case .jobTypeList:
            JobTypeListView()
        case .addJobType:
            AddJobTypeView()
        case .jobTypeDetail(let jobType):
            JobTypeDetailView(jobType: jobType)
        case .addScopeItemTemplate(let jobType):
            AddScopeItemTemplateView(jobType: jobType)
        }
    }
}
