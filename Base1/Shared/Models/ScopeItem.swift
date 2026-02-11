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
    public var quantityNeeded: Int
    public var laborHours: Decimal?
    public var costMarkup: Decimal?
    public var statusRaw: String
    public var notes: String?

    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    public var project: Project?
    public var resource: Resource?

    // MARK: - Computed

    public var status: ScopeItemStatus {
        get { ScopeItemStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    public var estimatedCost: Decimal? {
        guard let unitCost = resource?.unitCost else { return nil }
        let baseCost = unitCost * Decimal(quantityNeeded)
        if let markup = costMarkup {
            return baseCost * (1 + markup)
        }
        return baseCost
    }

    public var inventoryShortfall: Int {
        guard let resource else { return quantityNeeded }
        return max(0, quantityNeeded - resource.availableQuantity)
    }

    public var displayName: String {
        itemDescription ?? resource?.name ?? "Unnamed Item"
    }

    // MARK: - Init

    public init(
        businessKey: String,
        quantityNeeded: Int,
        laborHours: Decimal? = nil,
        costMarkup: Decimal? = nil,
        description: String? = nil,
        status: ScopeItemStatus = .pending
    ) {
        self.businessKey = businessKey
        self.quantityNeeded = quantityNeeded
        self.laborHours = laborHours
        self.costMarkup = costMarkup
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
