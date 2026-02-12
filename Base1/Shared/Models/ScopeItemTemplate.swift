//
//  ScopeItemTemplate.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

@Model
public final class ScopeItemTemplate {

    // MARK: - Fields

    public var businessKey: String
    public var name: String
    public var defaultQuantity: Decimal
    public var defaultLaborHours: Decimal?
    public var defaultFixedCost: Decimal?
    public var defaultCostMarkup: Decimal?
    public var defaultUnitRaw: String?
    public var notes: String?
    public var createdAt: Date

    // MARK: - Relationships

    public var resource: Resource?
    public var business: Business?
    public var jobType: JobType?

    // MARK: - Computed

    public var defaultUnit: UnitOfMeasure? {
        get {
            guard let raw = defaultUnitRaw else { return nil }
            return UnitOfMeasure(rawValue: raw)
        }
        set { defaultUnitRaw = newValue?.rawValue }
    }

    // MARK: - Init

    public init(
        businessKey: String,
        name: String,
        defaultQuantity: Decimal = 1,
        defaultLaborHours: Decimal? = nil,
        defaultFixedCost: Decimal? = nil,
        defaultCostMarkup: Decimal? = nil,
        defaultUnit: UnitOfMeasure? = nil
    ) {
        self.businessKey = businessKey
        self.name = name
        self.defaultQuantity = defaultQuantity
        self.defaultLaborHours = defaultLaborHours
        self.defaultFixedCost = defaultFixedCost
        self.defaultCostMarkup = defaultCostMarkup
        self.defaultUnitRaw = defaultUnit?.rawValue
        self.createdAt = .now
    }
}
