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
    public var invitedAt: Date
    public var acceptedAt: Date?
    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    public var business: Business?

    @Relationship(inverse: \Project.assignedMembers)
    public var assignedProjects: [Project] = []

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

    // MARK: - Init

    public init(
        businessKey: String,
        email: String,
        displayName: String,
        role: MemberRole = .member,
        inviteStatus: InviteStatus = .pending
    ) {
        self.businessKey = businessKey
        self.email = email
        self.displayName = displayName
        self.roleRaw = role.rawValue
        self.inviteStatusRaw = inviteStatus.rawValue
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
