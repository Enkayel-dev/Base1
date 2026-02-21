//
//  ScopeItem.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

@Model
public final class ScopeItem {

    // MARK: - Fields

    public var businessKey: String
    public var itemDescription: String?
    public var laborHours: Decimal?
    public var fixedCost: Decimal?
    public var costMarkup: Decimal?
    public var sortOrder: Int
    public var statusRaw: String
    public var assignedRoleRaw: String?
    public var notes: String?

    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    public var project: Project?
    public var assignedMember: Member?

    @Relationship(deleteRule: .cascade, inverse: \ScopeItemResource.scopeItem)
    public var scopeItemResources: [ScopeItemResource] = []

    // MARK: - Computed

    /// Status is derived automatically from the project's materialOrder milestone.
    public var status: ScopeItemStatus {
        get {
            guard let milestone = project?.milestones.first(where: { $0.milestoneType == .materialOrder }) else {
                return .pending
            }
            let now = Date.now
            if let endDate = milestone.endDate, now >= endDate {
                return .fulfilled
            }
            if now >= milestone.date {
                return .ordered
            }
            return .pending
        }
        set { statusRaw = newValue.rawValue }
    }

    public var assignedRole: MemberRole? {
        get {
            guard let raw = assignedRoleRaw else { return nil }
            return MemberRole(rawValue: raw)
        }
        set { assignedRoleRaw = newValue?.rawValue }
    }

    public var materialCost: Decimal {
        scopeItemResources.compactMap { $0.materialCost }.reduce(Decimal.zero, +)
    }

    public var laborCost: Decimal? {
        guard let hours = laborHours, let rate = assignedMember?.hourlyRate else { return nil }
        return hours * rate
    }

    public var estimatedCost: Decimal {
        materialCost + (laborCost ?? Decimal.zero)
    }

    public var hasInventoryIssues: Bool {
        scopeItemResources.contains { $0.inventoryShortfall > 0 }
    }

    public var displayName: String {
        if let desc = itemDescription, !desc.isEmpty { return desc }
        if let first = scopeItemResources.first?.resource?.name {
            let count = scopeItemResources.count
            return count > 1 ? "\(first) + \(count - 1) more" : first
        }
        return "Unnamed Item"
    }

    // MARK: - Init

    public init(
        businessKey: String,
        laborHours: Decimal? = nil,
        fixedCost: Decimal? = nil,
        costMarkup: Decimal? = nil,
        sortOrder: Int = 0,
        description: String? = nil,
        status: ScopeItemStatus = .pending
    ) {
        self.businessKey = businessKey
        self.laborHours = laborHours
        self.fixedCost = fixedCost
        self.costMarkup = costMarkup
        self.sortOrder = sortOrder
        self.itemDescription = description
        self.statusRaw = status.rawValue
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Scope Item Status

public enum ScopeItemStatus: String, Codable, CaseIterable, Identifiable {
    case pending
    case ordered
    case fulfilled

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .pending: "Pending"
        case .ordered: "Ordered"
        case .fulfilled: "Fulfilled"
        }
    }
}
