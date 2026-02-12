//
//  ScopeItemResource.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

@Model
public final class ScopeItemResource {

    // MARK: - Fields

    public var businessKey: String
    public var quantity: Decimal
    public var unitRaw: String
    public var createdAt: Date

    // MARK: - Relationships

    public var scopeItem: ScopeItem?
    public var resource: Resource?

    // MARK: - Computed

    public var unit: UnitOfMeasure {
        get { UnitOfMeasure(rawValue: unitRaw) ?? .each }
        set { unitRaw = newValue.rawValue }
    }

    public var materialCost: Decimal? {
        guard let unitCost = resource?.unitCost else { return nil }
        return quantity * unitCost
    }

    public var inventoryShortfall: Decimal {
        guard let resource else { return quantity }
        return max(0, quantity - resource.availableQuantity)
    }

    public var displayName: String {
        resource?.name ?? "Unknown Resource"
    }

    // MARK: - Init

    public init(
        businessKey: String,
        quantity: Decimal,
        unit: UnitOfMeasure = .each
    ) {
        self.businessKey = businessKey
        self.quantity = quantity
        self.unitRaw = unit.rawValue
        self.createdAt = .now
    }
}
