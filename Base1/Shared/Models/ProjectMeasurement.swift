//
//  ProjectMeasurement.swift
//  Base1
//
//  Created by Antigravity on 2026-02-12.
//

import SwiftUI
import SwiftData

@Model
public final class ProjectMeasurement {

    // MARK: - Fields

    public var businessKey: String
    public var name: String
    public var value: Decimal
    public var unitRaw: String
    public var notes: String?
    public var createdAt: Date

    // MARK: - Relationships

    public var project: Project?

    @Relationship(deleteRule: .nullify, inverse: \ScopeItemResource.measurements)
    public var scopeItemResources: [ScopeItemResource] = []

    // MARK: - Computed

    public var unit: UnitOfMeasure {
        get { UnitOfMeasure(rawValue: unitRaw) ?? .each }
        set { unitRaw = newValue.rawValue }
    }

    // MARK: - Init

    public init(
        businessKey: String,
        name: String,
        value: Decimal,
        unit: UnitOfMeasure,
        notes: String? = nil
    ) {
        self.businessKey = businessKey
        self.name = name
        self.value = value
        self.unitRaw = unit.rawValue
        self.notes = notes
        self.createdAt = .now
    }
}
