//
//  Member.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

@Model
public final class Member {

    // MARK: - Fields

    public var businessKey: String
    public var email: String
    public var displayName: String
    public var roleRaw: String
    public var inviteStatusRaw: String
    public var hourlyRate: Decimal?
    public var invitedAt: Date
    public var acceptedAt: Date?
    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Payroll Info

    public var bankName: String?
    public var accountNumber: String?
    public var transitNumber: String?
    public var sin: String? // Social Insurance Number

    // MARK: - Relationships

    public var business: Business?

    @Relationship(inverse: \Project.assignedMembers)
    public var assignedProjects: [Project] = []

    @Relationship(inverse: \ScopeItem.assignedMember)
    public var assignedScopeItems: [ScopeItem] = []

    @Relationship(inverse: \ProjectMilestone.assignedMember)
    public var assignedMilestones: [ProjectMilestone] = []

    // MARK: - Computed

    public var role: MemberRole {
        get { MemberRole(rawValue: roleRaw) ?? .member }
        set { roleRaw = newValue.rawValue }
    }

    public var inviteStatus: InviteStatus {
        get { InviteStatus(rawValue: inviteStatusRaw) ?? .pending }
        set { inviteStatusRaw = newValue.rawValue }
    }

    public var initials: String {
        let parts = displayName.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(displayName.prefix(2)).uppercased()
    }

    /// Calculated total hours worked across all assigned milestones that have a duration.
    public var hoursWorked: Double {
        assignedMilestones.reduce(0.0) { $0 + $1.duration }
    }

    /// Grouped milestones by project for time tracking display.
    public var milestonesByProject: [Project: [ProjectMilestone]] {
        Dictionary(grouping: assignedMilestones) { $0.project ?? Project(businessKey: "TEMP", title: "Unknown") }
            .filter { $0.key.title != "Unknown" }
    }

    // MARK: - Init

    public init(
        businessKey: String,
        email: String,
        displayName: String,
        role: MemberRole = .member,
        inviteStatus: InviteStatus = .pending,
        hourlyRate: Decimal? = nil
    ) {
        self.businessKey = businessKey
        self.email = email
        self.displayName = displayName
        self.roleRaw = role.rawValue
        self.inviteStatusRaw = inviteStatus.rawValue
        self.hourlyRate = hourlyRate
        self.invitedAt = .now
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Member Role

public enum MemberRole: String, Codable, CaseIterable, Identifiable {
    case owner
    case admin
    case member

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .owner: "Owner"
        case .admin: "Admin"
        case .member: "Member"
        }
    }
}

// MARK: - Invite Status

public enum InviteStatus: String, Codable, CaseIterable, Identifiable {
    case pending
    case accepted
    case declined

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .pending: "Pending"
        case .accepted: "Accepted"
        case .declined: "Declined"
        }
    }
}
