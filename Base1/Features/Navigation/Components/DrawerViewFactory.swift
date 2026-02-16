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
        case .memberDetail(let member):
            MemberDetailView(member: member)

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
        case .addMeasurement(let project):
            AddMeasurementView(project: project)
        case .addProjectPhoto(let project):
            AddProjectPhotoView(project: project)
        case .projectEstimate(let project):
            PDFPreviewView(project: project, business: project.business)
        case .addSchedule(let project, let type):
            AddScheduleView(project: project, milestoneType: type)

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
        }
    }
}
