//
//  DrawerViewFactory.swift
//  Base1
//

import SwiftUI
import SwiftData

struct DrawerViewFactory: View {
    let destination: DrawerDestination
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        switch destination {

        // Clients
        case .addClient:
            AddClientView()
        case .clientDetail(let id):
            if let client = modelContext.registeredModel(for: id) as Client? {
                ClientDetailView(client: client)
            }
        case .memberDetail(let id):
            if let member = modelContext.registeredModel(for: id) as Member? {
                MemberDetailView(member: member)
            }

        // Schedule
        case .addAppointment:
            AddAppointmentView()

        // Projects
        case .addProject:
            AddProjectView()
        case .projectDetail(let id):
            if let project = modelContext.registeredModel(for: id) as Project? {
                ProjectDetailView(project: project)
            }
        case .addScopeItem(let id):
            if let project = modelContext.registeredModel(for: id) as Project? {
                AddScopeItemView(project: project)
            }
        case .addMeasurement(let id):
            if let project = modelContext.registeredModel(for: id) as Project? {
                AddMeasurementView(project: project)
            }
        case .addProjectPhoto(let id):
            if let project = modelContext.registeredModel(for: id) as Project? {
                AddProjectPhotoView(project: project)
            }
        case .projectEstimate(let id):
            if let project = modelContext.registeredModel(for: id) as Project? {
                PDFPreviewView(project: project, business: project.business)
            }
        case .addSchedule(let id, let type):
            if let project = modelContext.registeredModel(for: id) as Project? {
                AddScheduleView(project: project, milestoneType: type)
            }

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
        case .materialVariants(let id):
            if let resource = modelContext.registeredModel(for: id) as Resource? {
                MaterialVariantsSheet(materialType: resource)
            }

        // Settings / Business
        case .inviteMember:
            InviteMemberView()
        }
    }
}
