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
    public var notes: String?

    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    public var project: Project?
    public var assignedMember: Member?

    @Relationship(deleteRule: .cascade, inverse: \ScopeItemResource.scopeItem)
    public var scopeItemResources: [ScopeItemResource] = []

    // MARK: - Computed

    public var status: ScopeItemStatus {
        get { ScopeItemStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    public var materialCost: Decimal {
        scopeItemResources.compactMap { $0.materialCost }.reduce(Decimal.zero, +)
    }

    public var laborCost: Decimal? {
        guard let hours = laborHours, let rate = assignedMember?.hourlyRate else { return nil }
        return hours * rate
    }

    public var estimatedCost: Decimal {
        let material = materialCost
        let labor = laborCost ?? Decimal.zero
        let fixed = fixedCost ?? Decimal.zero
        let subtotal = material + labor + fixed
        if let markup = costMarkup {
            return subtotal * (1 + markup)
        }
        return subtotal
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
