//
//  Resource.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

@Model
public final class Resource {

    // MARK: - Fields

    public var name: String
    public var resourceDescription: String?
    public var categoryRaw: String
    public var unitCost: Decimal?
    public var quantity: Int
    public var unit: String?
    public var isAvailable: Bool
    public var notes: String?

    @Attribute(.externalStorage)
    public var imageData: Data?

    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    public var business: Business?
    public var projects: [Project] = []

    // MARK: - Computed

    public var category: ResourceCategory {
        get { ResourceCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    public var totalValue: Decimal? {
        guard let unitCost else { return nil }
        return unitCost * Decimal(quantity)
    }

    public var assignedProjectCount: Int {
        projects.count
    }

    // MARK: - Init

    public init(
        name: String,
        description: String? = nil,
        category: ResourceCategory = .other,
        unitCost: Decimal? = nil,
        quantity: Int = 1,
        unit: String? = nil,
        isAvailable: Bool = true
    ) {
        self.name = name
        self.resourceDescription = description
        self.categoryRaw = category.rawValue
        self.unitCost = unitCost
        self.quantity = quantity
        self.unit = unit
        self.isAvailable = isAvailable
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Resource Category

public enum ResourceCategory: String, Codable, CaseIterable, Identifiable {
    case equipment
    case material
    case vehicle
    case tool
    case other

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .equipment: "Equipment"
        case .material: "Material"
        case .vehicle: "Vehicle"
        case .tool: "Tool"
        case .other: "Other"
        }
    }

    public var systemImage: String {
        switch self {
        case .equipment: "gearshape.2"
        case .material: "shippingbox"
        case .vehicle: "car"
        case .tool: "wrench.and.screwdriver"
        case .other: "questionmark.folder"
        }
    }
}
