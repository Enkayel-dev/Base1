//
//  Project.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

@Model
public final class Project {

    // MARK: - Fields

    public var businessKey: String
    public var title: String
    public var projectDescription: String?
    public var statusRaw: String
    public var projectTypeRaw: String?
    public var startDate: Date?
    public var dueDate: Date?
    public var completedDate: Date?
    public var estimatedBudget: Decimal?
    public var notes: String?

    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    public var business: Business?
    public var client: Client?

    @Relationship(deleteRule: .cascade, inverse: \Invoice.project)
    public var invoices: [Invoice] = []

    @Relationship(deleteRule: .nullify, inverse: \Resource.projects)
    public var resources: [Resource] = []

    @Relationship(deleteRule: .cascade, inverse: \Appointment.project)
    public var appointments: [Appointment] = []

    @Relationship(deleteRule: .cascade, inverse: \Workflow.project)
    public var workflows: [Workflow] = []

    @Relationship(deleteRule: .cascade, inverse: \ScopeItem.project)
    public var scopeItems: [ScopeItem] = []

    public var assignedMembers: [Member] = []

    // MARK: - Computed

    public var status: ProjectStatus {
        get { ProjectStatus(rawValue: statusRaw) ?? .planning }
        set { statusRaw = newValue.rawValue }
    }

    public var isOverdue: Bool {
        guard let dueDate, status != .completed && status != .cancelled else { return false }
        return dueDate < .now
    }

    public var totalInvoiced: Decimal {
        invoices.reduce(Decimal.zero) { $0 + $1.amount }
    }

    public var totalPaid: Decimal {
        invoices
            .filter { $0.status == .paid }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    public var totalScopeCost: Decimal {
        scopeItems.reduce(Decimal.zero) { $0 + $1.estimatedCost }
    }

    public var totalMaterialCost: Decimal {
        scopeItems.reduce(Decimal.zero) { $0 + $1.materialCost }
    }

    public var totalLaborCost: Decimal {
        scopeItems.compactMap { $0.laborCost }.reduce(Decimal.zero, +)
    }

    public var totalLaborHours: Decimal {
        scopeItems.compactMap { $0.laborHours }.reduce(Decimal.zero, +)
    }

    public var totalFixedCost: Decimal {
        scopeItems.compactMap { $0.fixedCost }.reduce(Decimal.zero, +)
    }

    public var hasInventoryIssues: Bool {
        scopeItems.contains { $0.hasInventoryIssues }
    }

    // MARK: - Init

    public init(
        businessKey: String,
        title: String,
        description: String? = nil,
        status: ProjectStatus = .planning,
        projectType: String? = nil,
        startDate: Date? = nil,
        dueDate: Date? = nil
    ) {
        self.businessKey = businessKey
        self.title = title
        self.projectDescription = description
        self.statusRaw = status.rawValue
        self.projectTypeRaw = projectType
        self.startDate = startDate
        self.dueDate = dueDate
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Project Status

public enum ProjectStatus: String, Codable, CaseIterable, Identifiable {
    case planning
    case inProgress
    case onHold
    case completed
    case cancelled

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .planning: "Planning"
        case .inProgress: "In Progress"
        case .onHold: "On Hold"
        case .completed: "Completed"
        case .cancelled: "Cancelled"
        }
    }
}

