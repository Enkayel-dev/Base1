//
//  SampleData.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

// MARK: - Sample Business

extension Business {
    static var sample: Business {
        Business(
            businessKey: "BUS_SAMPLE1",
            ownerAppleUserID: "SAMPLE_APPLE_USER",
            name: "Tremblay & Sons Construction",
            ownerName: "Nicholas Lachapelle",
            email: "info@tremcon.ca",
            phone: "514-555-0100"
        )
    }
}

// MARK: - Sample Clients

extension Client {
    static func sampleClients(forBusinessKey businessKey: String) -> [Client] {
        [
            Client(
                businessKey: businessKey,
                firstName: "Marie",
                lastName: "Tremblay",
                companyName: "Tremblay Construction",
                email: "marie@tremcon.ca",
                phone: "514-555-0101",
                status: .active
            ),
            Client(
                businessKey: businessKey,
                firstName: "Jean",
                lastName: "Gagnon",
                email: "jean.g@email.com",
                phone: "418-555-0202",
                status: .lead
            ),
            Client(
                businessKey: businessKey,
                firstName: "Sophie",
                lastName: "Roy",
                companyName: "Roy Design Studio",
                email: "sophie@roydesign.ca",
                status: .active
            ),
            Client(
                businessKey: businessKey,
                firstName: "Marc",
                lastName: "Lefebvre",
                email: "marc.l@email.com",
                status: .closed
            ),
        ]
    }
}

// MARK: - Sample Projects

extension Project {
    static func sampleProjects(businessKey: String, clients: [Client]) -> [Project] {
        guard clients.count >= 3 else { return [] }

        let p1 = Project(
            businessKey: businessKey,
            title: "Renovation for Tremblay",
            description: "Full kitchen remodel with custom cabinets",
            status: .inProgress,
            projectType: "Renovation",
            startDate: .now.addingTimeInterval(-30 * 86400),
            dueDate: .now.addingTimeInterval(60 * 86400)
        )
        p1.client = clients[0]

        let p2 = Project(
            businessKey: businessKey,
            title: "New Build for Tremblay",
            description: "New office partition walls and electrical",
            projectType: "New Build",
            dueDate: .now.addingTimeInterval(90 * 86400)
        )
        p2.client = clients[0]

        let p3 = Project(
            businessKey: businessKey,
            title: "Repair for Roy",
            status: .inProgress,
            projectType: "Repair",
            startDate: .now.addingTimeInterval(-14 * 86400),
            dueDate: .now.addingTimeInterval(21 * 86400)
        )
        p3.client = clients[2]

        return [p1, p2, p3]
    }
}

// MARK: - Sample Resources

extension Resource {
    static func sampleResources(businessKey: String) -> [Resource] {
        // Equipment
        let tableSaw = Resource(
            businessKey: businessKey,
            name: "Table Saw",
            category: .equipment,
            quantity: 1
        )

        // Material Types
        let sandpaperType = Resource(
            businessKey: businessKey,
            name: "Orbital Sand Paper",
            category: .material,
            materialTypeName: "Orbital Sand Paper"
        )

        let sandpaper40 = Resource(
            businessKey: businessKey,
            name: "Orbital Sand Paper — 40 grit",
            category: .material,
            unitCost: 2.50,
            quantity: 50,
            unit: .each,
            variantLabel: "40 grit"
        )
        sandpaper40.parentMaterial = sandpaperType

        let sandpaper60 = Resource(
            businessKey: businessKey,
            name: "Orbital Sand Paper — 60 grit",
            category: .material,
            unitCost: 2.50,
            quantity: 30,
            unit: .each,
            variantLabel: "60 grit"
        )
        sandpaper60.parentMaterial = sandpaperType

        let sandpaper80 = Resource(
            businessKey: businessKey,
            name: "Orbital Sand Paper — 80 grit",
            category: .material,
            unitCost: 2.75,
            quantity: 40,
            unit: .each,
            variantLabel: "80 grit"
        )
        sandpaper80.parentMaterial = sandpaperType

        let stainType = Resource(
            businessKey: businessKey,
            name: "Deck Stain",
            category: .material,
            materialTypeName: "Deck Stain",
            coverageRate: 200, // 200 sqft per gallon
            coverageUnit: .sqft,
            defaultWasteFactor: 0.1,
            defaultCoats: 2
        )

        let stainBrown = Resource(
            businessKey: businessKey,
            name: "Deck Stain — Chocolate Brown",
            category: .material,
            unitCost: 45.00,
            quantity: 10,
            unit: .gallons,
            variantLabel: "Chocolate Brown"
        )
        stainBrown.parentMaterial = stainType

        let stainCedar = Resource(
            businessKey: businessKey,
            name: "Deck Stain — Red Cedar",
            category: .material,
            unitCost: 45.00,
            quantity: 8,
            unit: .gallons,
            variantLabel: "Red Cedar"
        )
        stainCedar.parentMaterial = stainType

        // Standalone material (no parent type)
        let ceramicTile = Resource(
            businessKey: businessKey,
            name: "Ceramic Tile - White 12x12",
            category: .material,
            unitCost: 3.50,
            quantity: 200,
            unit: .sqft
        )

        // Vehicle
        let van = Resource(
            businessKey: businessKey,
            name: "Work Van #1",
            category: .vehicle,
            quantity: 1,
            vehicleMake: "Ford",
            vehicleModel: "Transit",
            startingKilometers: 45000
        )

        // Tools
        let orbitalSander = Resource(
            businessKey: businessKey,
            name: "Orbital Sander",
            category: .tool,
            quantity: 1,
            isShopTool: true
        )

        let drillSet = Resource(
            businessKey: businessKey,
            name: "Drill Set",
            category: .tool,
            quantity: 1
        )
        drillSet.assignedVehicle = van

        // Link equipment to materials
        tableSaw.equipmentMaterials = [sandpaperType]

        return [
            tableSaw,
            sandpaperType, sandpaper40, sandpaper60, sandpaper80,
            stainType, stainBrown, stainCedar,
            ceramicTile,
            van,
            orbitalSander, drillSet,
        ]
    }
}

// MARK: - Sample Measurements

extension ProjectMeasurement {
    static func sampleMeasurements(businessKey: String, project: Project) -> [ProjectMeasurement] {
        let m1 = ProjectMeasurement(
            businessKey: businessKey,
            name: "Main Deck Outer Area",
            value: 450,
            unit: .sqft
        )
        m1.project = project

        let m2 = ProjectMeasurement(
            businessKey: businessKey,
            name: "Railings Total Length",
            value: 60,
            unit: .feet
        )
        m2.project = project

        return [m1, m2]
    }
}

// MARK: - Sample Milestones

extension ProjectMilestone {
    static func sampleMilestones(businessKey: String, project: Project) -> [ProjectMilestone] {
        let m1 = ProjectMilestone(
            businessKey: businessKey,
            milestoneType: .created,
            date: project.createdAt
        )
        m1.project = project

        let m2 = ProjectMilestone(
            businessKey: businessKey,
            milestoneType: .estimateSent,
            date: project.createdAt.addingTimeInterval(86400) // 1 day later
        )
        m2.project = project

        return [m1, m2]
    }
}

// MARK: - Sample Scope Items

extension ScopeItem {
    static func sampleScopeItems(businessKey: String, projects: [Project], resources: [Resource], members: [Member]) -> [ScopeItem] {
        guard projects.count >= 3, resources.count >= 9, members.count >= 3 else { return [] }

        // Tile installation — material + labor
        let item1 = ScopeItem(
            businessKey: businessKey,
            laborHours: 12.0,
            costMarkup: 0.15,
            description: "White ceramic tile for bathroom walls",
            status: .ordered
        )
        item1.project = projects[2]
        item1.assignedMember = members[2]

        let item1Resource = ScopeItemResource(
            businessKey: businessKey,
            quantity: 150,
            unit: .sqft
        )
        item1Resource.resource = resources[8] // Ceramic Tile
        item1Resource.scopeItem = item1

        // Cabinet cuts — equipment + labor
        let item2 = ScopeItem(
            businessKey: businessKey,
            laborHours: 4.0,
            description: "Table saw for cabinet cuts",
            status: .fulfilled
        )
        item2.project = projects[0]
        item2.assignedMember = members[1]

        let item2Resource = ScopeItemResource(
            businessKey: businessKey,
            quantity: 1,
            unit: .each
        )
        item2Resource.resource = resources[0] // Table Saw
        item2Resource.scopeItem = item2

        return [item1, item2]
    }
}

// MARK: - Sample Scope Item Resources

extension ScopeItemResource {
    static func sampleScopeItemResources(from scopeItems: [ScopeItem]) -> [ScopeItemResource] {
        scopeItems.flatMap { $0.scopeItemResources }
    }
}

// MARK: - Sample Members

extension Member {
    static func sampleMembers(businessKey: String) -> [Member] {
        let owner = Member(
            businessKey: businessKey,
            email: "nick@tremcon.ca",
            displayName: "Nicholas Lachapelle",
            role: .owner,
            inviteStatus: .accepted,
            hourlyRate: 95.00
        )
        owner.acceptedAt = .now

        let admin = Member(
            businessKey: businessKey,
            email: "marie@tremcon.ca",
            displayName: "Marie Tremblay",
            role: .admin,
            inviteStatus: .accepted,
            hourlyRate: 75.00
        )
        admin.acceptedAt = .now.addingTimeInterval(-7 * 86400)

        let member = Member(
            businessKey: businessKey,
            email: "luc@tremcon.ca",
            displayName: "Luc Bergeron",
            role: .member,
            inviteStatus: .accepted,
            hourlyRate: 55.00
        )
        member.acceptedAt = .now.addingTimeInterval(-3 * 86400)

        let pending = Member(
            businessKey: businessKey,
            email: "alain@tremcon.ca",
            displayName: "Alain Dubois",
            role: .member,
            inviteStatus: .pending,
            hourlyRate: 45.00
        )

        return [owner, admin, member, pending]
    }
}

// MARK: - Sample Job Types

extension JobType {
    static func sampleJobTypes(businessKey: String) -> [JobType] {
        [
            JobType(businessKey: businessKey, name: "Renovation", icon: "hammer", sortOrder: 0),
            JobType(businessKey: businessKey, name: "New Build", icon: "house", sortOrder: 1),
            JobType(businessKey: businessKey, name: "Repair", icon: "wrench.and.screwdriver", sortOrder: 2),
        ]
    }
}

// MARK: - Sample Scope Item Templates

extension ScopeItemTemplate {
    static func sampleTemplates(businessKey: String, jobTypes: [JobType], resources: [Resource]) -> [ScopeItemTemplate] {
        guard jobTypes.count >= 3, resources.count >= 9 else { return [] }

        // resources[8] = Ceramic Tile, resources[0] = Table Saw
        let t1 = ScopeItemTemplate(
            businessKey: businessKey,
            name: "Tile Installation",
            defaultQuantity: 100,
            defaultLaborHours: 8.0,
            defaultCostMarkup: 0.15,
            defaultUnit: .sqft
        )
        t1.resource = resources[8]
        t1.jobType = jobTypes[0]

        let t2 = ScopeItemTemplate(
            businessKey: businessKey,
            name: "Cabinet Cuts",
            defaultQuantity: 1,
            defaultLaborHours: 4.0,
            defaultUnit: .each
        )
        t2.resource = resources[0]
        t2.jobType = jobTypes[0]

        let t3 = ScopeItemTemplate(
            businessKey: businessKey,
            name: "General Tile Work",
            defaultQuantity: 50,
            defaultLaborHours: 6.0,
            defaultUnit: .sqft
        )
        t3.resource = resources[8]
        t3.jobType = jobTypes[2]

        return [t1, t2, t3]
    }
}

// MARK: - Sample Invoices

extension Invoice {
    static func sampleInvoices(businessKey: String, clients: [Client], projects: [Project]) -> [Invoice] {
        guard clients.count >= 3, projects.count >= 3 else { return [] }

        let inv1 = Invoice(
            businessKey: businessKey,
            invoiceNumber: "INV-2026-0001",
            title: "Kitchen Phase 1 - Demolition",
            amount: 4500.00,
            taxRate: 0.14975,
            dueDate: .now.addingTimeInterval(30 * 86400)
        )
        inv1.client = clients[0]
        inv1.project = projects[0]

        let inv2 = Invoice(
            businessKey: businessKey,
            invoiceNumber: "INV-2026-0002",
            title: "Tile Materials Deposit",
            amount: 1200.00,
            taxRate: 0.14975,
            dueDate: .now.addingTimeInterval(-5 * 86400)
        )
        inv2.client = clients[2]
        inv2.project = projects[2]

        return [inv1, inv2]
    }
}

// MARK: - Sample Appointments

extension Appointment {
    static func sampleAppointments(businessKey: String, clients: [Client], projects: [Project]) -> [Appointment] {
        guard clients.count >= 2, projects.count >= 1 else { return [] }

        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.startOfDay(for: .now.addingTimeInterval(86400))

        // Today — morning meeting
        let t1 = Appointment(
            businessKey: businessKey,
            title: "Team Standup",
            type: .meeting,
            startDate: today.addingTimeInterval(8 * 3600),
            endDate: today.addingTimeInterval(9 * 3600)
        )

        // Today — overlapping midday events
        let t2 = Appointment(
            businessKey: businessKey,
            title: "Client Lunch Meeting",
            type: .consultation,
            startDate: today.addingTimeInterval(12 * 3600),
            endDate: today.addingTimeInterval(13 * 3600),
            location: "Café du Marché"
        )
        t2.client = clients[0]

        let t3 = Appointment(
            businessKey: businessKey,
            title: "Supplier Call",
            type: .followUp,
            startDate: today.addingTimeInterval(12.5 * 3600),
            endDate: today.addingTimeInterval(13.5 * 3600)
        )

        // Today — afternoon site visit
        let t4 = Appointment(
            businessKey: businessKey,
            title: "Bathroom Tile Inspection",
            type: .siteVisit,
            startDate: today.addingTimeInterval(15 * 3600),
            endDate: today.addingTimeInterval(16.5 * 3600),
            location: "456 Rue des Érables"
        )
        t4.client = clients[2]
        t4.project = projects[2]

        // Today — all-day event
        let t5 = Appointment(
            businessKey: businessKey,
            title: "Permit Deadline",
            type: .delivery,
            startDate: today,
            endDate: today.addingTimeInterval(86399),
            isAllDay: true
        )

        // Tomorrow — existing events
        let a1 = Appointment(
            businessKey: businessKey,
            title: "Kitchen Site Visit",
            type: .siteVisit,
            startDate: tomorrow.addingTimeInterval(9 * 3600),
            endDate: tomorrow.addingTimeInterval(10 * 3600),
            location: "123 Rue Principale"
        )
        a1.client = clients[0]
        a1.project = projects[0]

        let a2 = Appointment(
            businessKey: businessKey,
            title: "New Lead Consultation",
            type: .consultation,
            startDate: tomorrow.addingTimeInterval(14 * 3600),
            endDate: tomorrow.addingTimeInterval(15 * 3600)
        )
        a2.client = clients[1]

        return [t1, t2, t3, t4, t5, a1, a2]
    }
}

// MARK: - Sample Workflow Template

extension WorkflowTemplate {
    static func sampleNewLeadTemplate(businessKey: String) -> WorkflowTemplate {
        let template = WorkflowTemplate(
            businessKey: businessKey,
            title: "New Lead Workflow",
            icon: "list.bullet",
            iconColor: .blue,
            category: .clientOnboarding,
            isSystemTemplate: true
        )

        template.stepTemplates = [
            WorkflowStepTemplate(
                title: "Fill client info",
                subtitle: "Complete all empty fields",
                viewKey: "ClientInfoView",
                sortOrder: 0
            ),
            WorkflowStepTemplate(
                title: "Schedule Visit",
                subtitle: "Pick a date for on-site visit",
                viewKey: "ScheduleView",
                sortOrder: 1
            ),
            WorkflowStepTemplate(
                title: "Project Setup",
                subtitle: "Prepare project tab",
                viewKey: "ProjectView",
                sortOrder: 2
            ),
        ]

        return template
    }
}

// MARK: - Preview Container

@MainActor
enum SampleDataContainer {
    static var preview: ModelContainer {
        let schema = Schema(Base1SchemaV1.models)
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: schema,
            configurations: [config]
        )
        let context = container.mainContext
        let bk = "BUS_SAMPLE1"

        // Business
        let business = Business.sample
        context.insert(business)

        // Clients
        let clients = Client.sampleClients(forBusinessKey: bk)
        clients.forEach { client in
            client.business = business
            context.insert(client)
        }

        // Projects
        let projects = Project.sampleProjects(businessKey: bk, clients: clients)
        projects.forEach { project in
            project.business = business
            context.insert(project)

            // Add sample measurements to first project
            if project === projects.first {
                ProjectMeasurement.sampleMeasurements(businessKey: bk, project: project)
                    .forEach { context.insert($0) }
                ProjectMilestone.sampleMilestones(businessKey: bk, project: project)
                    .forEach { context.insert($0) }
            }
        }

        // Resources
        let resources = Resource.sampleResources(businessKey: bk)
        resources.forEach { resource in
            resource.business = business
            context.insert(resource)
        }

        // Assign resources to projects
        if projects.count >= 3, resources.count >= 9 {
            projects[0].resources.append(resources[0])  // Table Saw
            projects[2].resources.append(resources[8])  // Ceramic Tile
        }

        // Members
        let members = Member.sampleMembers(businessKey: bk)
        members.forEach { member in
            member.business = business
            context.insert(member)
        }

        // Assign members to projects
        if projects.count >= 3, members.count >= 3 {
            projects[0].assignedMembers = [members[0], members[1], members[2]]
            projects[1].assignedMembers = [members[0], members[1]]
            projects[2].assignedMembers = [members[2]]
        }

        // Job Types
        let jobTypes = JobType.sampleJobTypes(businessKey: bk)
        jobTypes.forEach { jt in
            jt.business = business
            context.insert(jt)
        }

        // Scope Item Templates
        let scopeTemplates = ScopeItemTemplate.sampleTemplates(businessKey: bk, jobTypes: jobTypes, resources: resources)
        scopeTemplates.forEach { st in
            st.business = business
            context.insert(st)
        }

        // Scope Items
        let scopeItems = ScopeItem.sampleScopeItems(businessKey: bk, projects: projects, resources: resources, members: members)
        scopeItems.forEach { scopeItem in
            context.insert(scopeItem)
            scopeItem.scopeItemResources.forEach { context.insert($0) }
        }

        // Invoices
        Invoice.sampleInvoices(businessKey: bk, clients: clients, projects: projects)
            .forEach { context.insert($0) }

        // Appointments
        Appointment.sampleAppointments(businessKey: bk, clients: clients, projects: projects)
            .forEach { context.insert($0) }

        // Workflow Template
        let template = WorkflowTemplate.sampleNewLeadTemplate(businessKey: bk)
        template.business = business
        context.insert(template)

        return container
    }
}
