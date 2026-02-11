//
//  JobType.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

@Model
public final class JobType {

    // MARK: - Fields

    public var businessKey: String
    public var name: String
    public var icon: String
    public var sortOrder: Int
    public var createdAt: Date

    // MARK: - Relationships

    public var business: Business?

    @Relationship(deleteRule: .cascade, inverse: \ScopeItemTemplate.jobType)
    public var scopeItemTemplates: [ScopeItemTemplate] = []

    // MARK: - Init

    public init(
        businessKey: String,
        name: String,
        icon: String = "hammer",
        sortOrder: Int = 0
    ) {
        self.businessKey = businessKey
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
        self.createdAt = .now
    }
}
