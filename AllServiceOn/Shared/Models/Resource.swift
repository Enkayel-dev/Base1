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

    // MARK: - Common Fields

    public var businessKey: String
    public var name: String
    public var resourceDescription: String?
    public var categoryRaw: String
    public var unitCost: Decimal?
    public var quantity: Decimal
    public var unitRaw: String
    public var isAvailable: Bool
    public var notes: String?

    @Attribute(.externalStorage)
    public var imageData: Data?

    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Material-Specific Fields

    public var materialTypeName: String?
    public var variantLabel: String?

    // MARK: - Coverage Fields (Materials)

    public var coverageRate: Decimal?
    public var coverageUnitRaw: String? // UnitOfMeasure
    public var defaultWasteFactor: Decimal? // e.g., 0.10 for 10%
    public var defaultCoats: Int?

    // MARK: - Packaging & Consumption Fields

    public var unitsPerPackage: Decimal? // e.g., 5 sheets per set
    public var consumptionUnitLabel: String? // e.g., "Sheet", "Ounce"

    // MARK: - Vehicle-Specific Fields

    public var vehicleMake: String?
    public var vehicleModel: String?
    public var startingKilometers: Int?
    public var serviceNotes: String?

    // MARK: - Tool-Specific Fields

    public var isShopTool: Bool

    // MARK: - Common Relationships

    public var business: Business?
    public var projects: [Project] = []

    @Relationship(deleteRule: .nullify, inverse: \ScopeItemResource.resource)
    public var scopeItemResources: [ScopeItemResource] = []

    // MARK: - Equipment Relationships

    @Relationship(deleteRule: .nullify, inverse: \Resource.usedByEquipment)
    public var equipmentMaterials: [Resource] = []

    public var usedByEquipment: [Resource] = []

    // MARK: - Material Relationships

    public var parentMaterial: Resource?

    @Relationship(deleteRule: .cascade, inverse: \Resource.parentMaterial)
    public var materialVariants: [Resource] = []

    // MARK: - Tool Relationships

    public var assignedVehicle: Resource?

    @Relationship(deleteRule: .nullify, inverse: \Resource.assignedVehicle)
    public var assignedTools: [Resource] = []

    // MARK: - Computed

    public var category: ResourceCategory {
        get { ResourceCategory(rawValue: categoryRaw) ?? .equipment }
        set { categoryRaw = newValue.rawValue }
    }

    public var unit: UnitOfMeasure {
        get { UnitOfMeasure(rawValue: unitRaw) ?? .each }
        set { unitRaw = newValue.rawValue }
    }

    public var coverageUnit: UnitOfMeasure? {
        get { coverageUnitRaw.flatMap { UnitOfMeasure(rawValue: $0) } }
        set { coverageUnitRaw = newValue?.rawValue }
    }

    public var totalValue: Decimal? {
        guard let unitCost else { return nil }
        return unitCost * quantity
    }

    public var assignedProjectCount: Int {
        projects.count
    }

    public var allocatedQuantity: Decimal {
        scopeItemResources.reduce(Decimal.zero) { $0 + $1.quantity }
    }

    public var availableQuantity: Decimal {
        quantity - allocatedQuantity
    }

    public var isMaterialType: Bool {
        category == .material && materialTypeName != nil && parentMaterial == nil
    }

    public var isMaterialVariant: Bool {
        category == .material && parentMaterial != nil
    }

    public var toolLocationLabel: String {
        if isShopTool { return "Shop" }
        if let vehicle = assignedVehicle { return vehicle.name }
        return "Unassigned"
    }

    public var vehicleDisplayLabel: String {
        [vehicleMake, vehicleModel].compactMap { $0 }.joined(separator: " ")
    }

    // MARK: - Init

    public init(
        businessKey: String,
        name: String,
        description: String? = nil,
        category: ResourceCategory = .equipment,
        unitCost: Decimal? = nil,
        quantity: Decimal = 1,
        unit: UnitOfMeasure = .each,
        isAvailable: Bool = true,
        materialTypeName: String? = nil,
        variantLabel: String? = nil,
        vehicleMake: String? = nil,
        vehicleModel: String? = nil,
        startingKilometers: Int? = nil,
        serviceNotes: String? = nil,
        isShopTool: Bool = false,
        coverageRate: Decimal? = nil,
        coverageUnit: UnitOfMeasure? = nil,
        defaultWasteFactor: Decimal? = nil,
        defaultCoats: Int? = nil,
        unitsPerPackage: Decimal? = nil,
        consumptionUnitLabel: String? = nil
    ) {
        self.businessKey = businessKey
        self.name = name
        self.resourceDescription = description
        self.categoryRaw = category.rawValue
        self.unitCost = unitCost
        self.quantity = quantity
        self.unitRaw = unit.rawValue
        self.isAvailable = isAvailable
        self.materialTypeName = materialTypeName
        self.variantLabel = variantLabel
        self.vehicleMake = vehicleMake
        self.vehicleModel = vehicleModel
        self.startingKilometers = startingKilometers
        self.serviceNotes = serviceNotes
        self.isShopTool = isShopTool
        self.coverageRate = coverageRate
        self.coverageUnitRaw = coverageUnit?.rawValue
        self.defaultWasteFactor = defaultWasteFactor
        self.defaultCoats = defaultCoats
        self.unitsPerPackage = unitsPerPackage
        self.consumptionUnitLabel = consumptionUnitLabel
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

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .equipment: "Equipment"
        case .material: "Material"
        case .vehicle: "Vehicle"
        case .tool: "Tool"
        }
    }

    public var systemImage: String {
        switch self {
        case .equipment: "gearshape.2"
        case .material: "shippingbox"
        case .vehicle: "car"
        case .tool: "wrench.and.screwdriver"
        }
    }
}
