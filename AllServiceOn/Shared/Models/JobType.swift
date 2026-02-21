//
//  JobType.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

@Model
public final class JobType: Identifiable, Hashable {

    // MARK: - Fields

    public var businessKey: String
    public var name: String
    public var icon: String
    public var sortOrder: Int
    public var variantDescription: String?
    public var createdAt: Date

    // MARK: - Relationships

    public var business: Business?

    @Relationship(deleteRule: .nullify, inverse: \JobType.children)
    public var parent: JobType?
    public var children: [JobType] = []

    @Relationship(deleteRule: .nullify, inverse: \Project.jobType)
    public var projects: [Project] = []

    @Relationship(deleteRule: .cascade, inverse: \ScopeItemTemplate.jobType)
    public var scopeItemTemplates: [ScopeItemTemplate] = []

    // MARK: - Computed

    public var templateProject: Project? {
        projects.first { $0.status == .template }
    }

    // MARK: - Init

    public init(
        businessKey: String,
        name: String,
        icon: String = "hammer",
        sortOrder: Int = 0,
        variantDescription: String? = nil,
        parent: JobType? = nil
    ) {
        self.businessKey = businessKey
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
        self.variantDescription = variantDescription
        self.parent = parent
        self.createdAt = .now
    }
}
