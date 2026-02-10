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
            businessKey: "BUS_SAMPLE1",            // sample key
            ownerAppleUserID: "SAMPLE_APPLE_USER", // sample Apple ID
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
    static func sampleProjects(clients: [Client]) -> [Project] {
        guard clients.count >= 3 else { return [] }

        let p1 = Project(
            title: "Kitchen Renovation",
            description: "Full kitchen remodel with custom cabinets",
            status: .inProgress,
            priority: .high,
            startDate: .now.addingTimeInterval(-30 * 86400),
            dueDate: .now.addingTimeInterval(60 * 86400)
        )
        p1.client = clients[0]

        let p2 = Project(
            title: "Office Buildout",
            description: "New office partition walls and electrical",
            status: .planning,
            priority: .medium,
            dueDate: .now.addingTimeInterval(90 * 86400)
        )
        p2.client = clients[0]

        let p3 = Project(
            title: "Bathroom Tile Work",
            status: .inProgress,
            priority: .medium,
            startDate: .now.addingTimeInterval(-14 * 86400),
            dueDate: .now.addingTimeInterval(21 * 86400)
        )
        p3.client = clients[2]

        return [p1, p2, p3]
    }
}

// MARK: - Sample Resources

extension Resource {
    static var sampleResources: [Resource] {
        [
            Resource(name: "Table Saw", category: .tool, quantity: 1),
            Resource(
                name: "Ceramic Tile - White 12x12",
                category: .material,
                unitCost: 3.50,
                quantity: 200,
                unit: "sqft"
            ),
            Resource(name: "Work Van #1", category: .vehicle, quantity: 1),
        ]
    }
}

// MARK: - Sample Invoices

extension Invoice {
    static func sampleInvoices(clients: [Client], projects: [Project]) -> [Invoice] {
        guard clients.count >= 3, projects.count >= 3 else { return [] }

        let inv1 = Invoice(
            invoiceNumber: "INV-2026-0001",
            title: "Kitchen Phase 1 - Demolition",
            amount: 4500.00,
            taxRate: 0.14975,
            dueDate: .now.addingTimeInterval(30 * 86400)
        )
        inv1.client = clients[0]
        inv1.project = projects[0]

        let inv2 = Invoice(
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
    static func sampleAppointments(clients: [Client], projects: [Project]) -> [Appointment] {
        guard clients.count >= 2, projects.count >= 1 else { return [] }

        let tomorrow = Calendar.current.startOfDay(for: .now.addingTimeInterval(86400))

        let a1 = Appointment(
            title: "Kitchen Site Visit",
            type: .siteVisit,
            startDate: tomorrow.addingTimeInterval(9 * 3600),
            endDate: tomorrow.addingTimeInterval(10 * 3600),
            location: "123 Rue Principale"
        )
        a1.client = clients[0]
        a1.project = projects[0]

        let a2 = Appointment(
            title: "New Lead Consultation",
            type: .consultation,
            startDate: tomorrow.addingTimeInterval(14 * 3600),
            endDate: tomorrow.addingTimeInterval(15 * 3600)
        )
        a2.client = clients[1]

        return [a1, a2]
    }
}

// MARK: - Sample Workflow Template

extension WorkflowTemplate {
    static var sampleNewLeadTemplate: WorkflowTemplate {
        let template = WorkflowTemplate(
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

        // Business
        let business = Business.sample
        context.insert(business)

        // Clients
        let clients = Client.sampleClients(forBusinessKey: business.businessKey)
        clients.forEach { client in
            client.business = business
            context.insert(client)
        }

        // Projects
        let projects = Project.sampleProjects(clients: clients)
        projects.forEach { project in
            project.business = business
            context.insert(project)
        }

        // Resources
        let resources = Resource.sampleResources
        resources.forEach { resource in
            resource.business = business
            context.insert(resource)
        }

        // Assign resources to projects
        if projects.count >= 3, resources.count >= 2 {
            projects[0].resources.append(resources[0])
            projects[2].resources.append(resources[1])
        }

        // Invoices
        Invoice.sampleInvoices(clients: clients, projects: projects)
            .forEach { context.insert($0) }

        // Appointments
        Appointment.sampleAppointments(clients: clients, projects: projects)
            .forEach { context.insert($0) }

        // Workflow Template
        let template = WorkflowTemplate.sampleNewLeadTemplate
        template.business = business
        context.insert(template)


        return container
    }
}
