//
//  Client.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

@Model
public final class Client {

    // MARK: - Fields
    public var businessKey: String   // ← REQUIRED for tenancy
    public var firstName: String
    public var lastName: String
    public var companyName: String?
    public var email: String?
    public var phone: String?
    public var address: String?
    public var notes: String?
    public var statusRaw: String

    @Attribute(.externalStorage)
    public var avatarData: Data?

    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    public var business: Business?

    @Relationship(deleteRule: .cascade, inverse: \Project.client)
    public var projects: [Project] = []

    @Relationship(deleteRule: .cascade, inverse: \Appointment.client)
    public var appointments: [Appointment] = []

    @Relationship(deleteRule: .cascade, inverse: \Invoice.client)
    public var invoices: [Invoice] = []

    @Relationship(deleteRule: .cascade, inverse: \Workflow.client)
    public var workflows: [Workflow] = []

    // MARK: - Computed

    public var displayName: String {
        if let companyName, !companyName.isEmpty {
            return companyName
        }
        return "\(firstName) \(lastName)"
    }

    public var status: ClientStatus {
        get { ClientStatus(rawValue: statusRaw) ?? .lead }
        set { statusRaw = newValue.rawValue }
    }

    public var activeProjectCount: Int {
        projects.filter { $0.status == .inProgress }.count
    }

    public var totalRevenue: Decimal {
        invoices
            .filter { $0.status == .paid }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    // MARK: - Init

    public init(
        firstName: String,
        lastName: String,
        companyName: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        address: String? = nil,
        status: ClientStatus = .lead
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.companyName = companyName
        self.email = email
        self.phone = phone
        self.address = address
        self.statusRaw = status.rawValue
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Client Status

public enum ClientStatus: String, Codable, CaseIterable, Identifiable {
    case lead
    case active
    case closed

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .lead: "Lead"
        case .active: "Active"
        case .closed: "Closed"
        }
    }
}
