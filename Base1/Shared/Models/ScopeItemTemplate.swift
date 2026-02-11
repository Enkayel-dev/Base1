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
    public var defaultQuantity: Int
    public var defaultLaborHours: Decimal?
    public var defaultCostMarkup: Decimal?
    public var notes: String?
    public var createdAt: Date

    // MARK: - Relationships

    public var resource: Resource?
    public var business: Business?
    public var jobType: JobType?

    // MARK: - Init

    public init(
        businessKey: String,
        name: String,
        defaultQuantity: Int = 1,
        defaultLaborHours: Decimal? = nil,
        defaultCostMarkup: Decimal? = nil
    ) {
        self.businessKey = businessKey
        self.name = name
        self.defaultQuantity = defaultQuantity
        self.defaultLaborHours = defaultLaborHours
        self.defaultCostMarkup = defaultCostMarkup
        self.createdAt = .now
    }
}
