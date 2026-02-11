//
//  WorkflowTemplate.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

// MARK: - Workflow Template

@Model
public final class WorkflowTemplate {

    // MARK: - Fields

    public var businessKey: String
    public var title: String
    public var icon: String
    public var iconColorHex: String
    public var categoryRaw: String
    public var isSystemTemplate: Bool

    public var createdAt: Date

    // MARK: - Relationships

    public var business: Business?

    @Relationship(deleteRule: .cascade, inverse: \WorkflowStepTemplate.template)
    public var stepTemplates: [WorkflowStepTemplate] = []

    @Relationship(deleteRule: .nullify, inverse: \Workflow.template)
    public var instances: [Workflow] = []

    // MARK: - Computed

    public var category: WorkflowCategory {
        get { WorkflowCategory(rawValue: categoryRaw) ?? .general }
        set { categoryRaw = newValue.rawValue }
    }

    public var iconColor: Color {
        Color(hex: iconColorHex) ?? .blue
    }

    public var sortedStepTemplates: [WorkflowStepTemplate] {
        stepTemplates.sorted { $0.sortOrder < $1.sortOrder }
    }

    // MARK: - Init

    public init(
        businessKey: String,
        title: String,
        icon: String = "list.bullet",
        iconColor: Color = .blue,
        category: WorkflowCategory = .general,
        isSystemTemplate: Bool = false
    ) {
        self.businessKey = businessKey
        self.title = title
        self.icon = icon
        self.iconColorHex = iconColor.toHex() ?? "#0000FF"
        self.categoryRaw = category.rawValue
        self.isSystemTemplate = isSystemTemplate
        self.createdAt = .now
    }
}

// MARK: - Workflow Step Template

@Model
public final class WorkflowStepTemplate {

    // MARK: - Fields

    public var title: String
    public var subtitle: String?
    public var viewKey: String
    public var requiresAction: Bool
    public var sortOrder: Int

    // MARK: - Relationships

    public var template: WorkflowTemplate?

    // MARK: - Init

    public init(
        title: String,
        subtitle: String? = nil,
        viewKey: String,
        requiresAction: Bool = true,
        sortOrder: Int = 0
    ) {
        self.title = title
        self.subtitle = subtitle
        self.viewKey = viewKey
        self.requiresAction = requiresAction
        self.sortOrder = sortOrder
    }
}

// MARK: - Workflow Category

public enum WorkflowCategory: String, Codable, CaseIterable, Identifiable {
    case clientOnboarding
    case projectKickoff
    case invoicing
    case scheduling
    case general

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .clientOnboarding: "Client Onboarding"
        case .projectKickoff: "Project Kickoff"
        case .invoicing: "Invoicing"
        case .scheduling: "Scheduling"
        case .general: "General"
        }
    }
}
