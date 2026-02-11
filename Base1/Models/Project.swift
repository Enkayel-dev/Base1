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
    public var priorityRaw: String
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

    // MARK: - Computed

    public var status: ProjectStatus {
        get { ProjectStatus(rawValue: statusRaw) ?? .planning }
        set { statusRaw = newValue.rawValue }
    }

    public var priority: ProjectPriority {
        get { ProjectPriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
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

    // MARK: - Init

    public init(
        businessKey: String,
        title: String,
        description: String? = nil,
        status: ProjectStatus = .planning,
        priority: ProjectPriority = .medium,
        startDate: Date? = nil,
        dueDate: Date? = nil
    ) {
        self.businessKey = businessKey
        self.title = title
        self.projectDescription = description
        self.statusRaw = status.rawValue
        self.priorityRaw = priority.rawValue
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

// MARK: - Project Priority

public enum ProjectPriority: String, Codable, CaseIterable, Identifiable {
    case low
    case medium
    case high
    case urgent

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        case .urgent: "Urgent"
        }
    }
}
