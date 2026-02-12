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
