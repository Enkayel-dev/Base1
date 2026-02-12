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
    public var wasteFactor: Decimal?
    public var coats: Int?
    public var isQuantityOverridden: Bool = false
    public var createdAt: Date

    // MARK: - Relationships

    public var scopeItem: ScopeItem?
    public var resource: Resource?
    public var measurements: [ProjectMeasurement] = []

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

    public var calculatedQuantity: Decimal? {
        guard !measurements.isEmpty,
              let resource,
              let rate = resource.coverageRate,
              rate > 0 else { return nil }

        let coverageUnit = resource.coverageUnit ?? .sqft
        var totalConvertedValue: Decimal = 0
        
        for measurement in measurements {
            if let converted = measurement.unit.convert(measurement.value, to: coverageUnit) {
                totalConvertedValue += converted
            }
        }
        
        if totalConvertedValue == 0 { return nil }

        let usageUnits = (totalConvertedValue / rate)
        let coatMultiplier = Decimal(coats ?? resource.defaultCoats ?? 1)
        let waste = 1 + (wasteFactor ?? resource.defaultWasteFactor ?? 0)
        
        let inventoryQty = usageUnits * coatMultiplier * waste

        // The result is directly in the resource's primary unit (e.g., Sets)
        return inventoryQty
    }

    public var displayName: String {
        resource?.name ?? "Unknown Resource"
    }

    // MARK: - Init

    public init(
        businessKey: String,
        quantity: Decimal,
        unit: UnitOfMeasure = .each,
        wasteFactor: Decimal? = nil,
        coats: Int? = nil,
        isQuantityOverridden: Bool = false
    ) {
        self.businessKey = businessKey
        self.quantity = quantity
        self.unitRaw = unit.rawValue
        self.wasteFactor = wasteFactor
        self.coats = coats
        self.isQuantityOverridden = isQuantityOverridden
        self.createdAt = .now
    }
}
