//
//  UnitOfMeasure.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import Foundation

public enum UnitOfMeasure: String, Codable, CaseIterable, Identifiable {

    // Count
    case each
    case pair
    case set

    // Length
    case feet
    case meters
    case inches

    // Area
    case sqft
    case sqm

    // Volume
    case gallons
    case liters
    case cubicYards

    // Weight
    case pounds
    case kilograms
    case tons

    // Time
    case hours
    case days

    // Flat
    case lumpSum

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .each: "Each"
        case .pair: "Pair"
        case .set: "Set"
        case .feet: "Feet"
        case .meters: "Meters"
        case .inches: "Inches"
        case .sqft: "Sq Ft"
        case .sqm: "Sq M"
        case .gallons: "Gallons"
        case .liters: "Liters"
        case .cubicYards: "Cubic Yards"
        case .pounds: "Pounds"
        case .kilograms: "Kilograms"
        case .tons: "Tons"
        case .hours: "Hours"
        case .days: "Days"
        case .lumpSum: "Lump Sum"
        }
    }

    public var abbreviation: String {
        switch self {
        case .each: "ea"
        case .pair: "pr"
        case .set: "set"
        case .feet: "ft"
        case .meters: "m"
        case .inches: "in"
        case .sqft: "sqft"
        case .sqm: "sqm"
        case .gallons: "gal"
        case .liters: "L"
        case .cubicYards: "yd³"
        case .pounds: "lb"
        case .kilograms: "kg"
        case .tons: "t"
        case .hours: "hr"
        case .days: "day"
        case .lumpSum: "LS"
        }
    }

    public var category: UnitCategory {
        switch self {
        case .each, .pair, .set: .count
        case .feet, .meters, .inches: .length
        case .sqft, .sqm: .area
        case .gallons, .liters, .cubicYards: .volume
        case .pounds, .kilograms, .tons: .weight
        case .hours, .days: .time
        case .lumpSum: .flat
        }
    }

    public static func grouped() -> [(category: UnitCategory, units: [UnitOfMeasure])] {
        UnitCategory.allCases.map { cat in
            (category: cat, units: allCases.filter { $0.category == cat })
        }
    }

    // MARK: - Conversions

    private var baseFactor: Decimal {
        switch self {
        // Length (Base: meters)
        case .meters: 1
        case .feet: 0.3048
        case .inches: 0.0254

        // Area (Base: sqm)
        case .sqm: 1
        case .sqft: 0.092903

        // Volume (Base: liters)
        case .liters: 1
        case .gallons: 3.78541
        case .cubicYards: 764.555

        // Weight (Base: kilograms)
        case .kilograms: 1
        case .pounds: 0.453592
        case .tons: 907.185 // US Ton

        // Time (Base: hours)
        case .hours: 1
        case .days: 24

        default: 1
        }
    }

    public func convert(_ value: Decimal, to other: UnitOfMeasure) -> Decimal? {
        guard self.category == other.category else { return nil }
        if self == other { return value }

        // Convert to base unit then to target unit
        let baseValue = value * self.baseFactor
        return baseValue / other.baseFactor
    }
}

// MARK: - Unit Category

public enum UnitCategory: String, CaseIterable, Identifiable {
    case count
    case length
    case area
    case volume
    case weight
    case time
    case flat

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .count: "Count"
        case .length: "Length"
        case .area: "Area"
        case .volume: "Volume"
        case .weight: "Weight"
        case .time: "Time"
        case .flat: "Flat"
        }
    }
}
