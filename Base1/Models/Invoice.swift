//
//  Invoice.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

@Model
public final class Invoice {

    // MARK: - Fields

    public var businessKey: String

    @Attribute(.unique)
    public var invoiceNumber: String

    public var title: String
    public var invoiceDescription: String?
    public var statusRaw: String
    public var amount: Decimal
    public var taxRate: Decimal
    public var currency: String
    public var issueDate: Date
    public var dueDate: Date
    public var paidDate: Date?
    public var notes: String?

    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    public var client: Client?
    public var project: Project?

    // MARK: - Computed

    public var status: InvoiceStatus {
        get { InvoiceStatus(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }

    public var taxAmount: Decimal {
        amount * taxRate
    }

    public var totalWithTax: Decimal {
        amount + taxAmount
    }

    public var isOverdue: Bool {
        status != .paid && status != .cancelled && dueDate < .now
    }

    public var effectiveStatus: InvoiceStatus {
        if status == .sent && isOverdue {
            return .overdue
        }
        return status
    }

    // MARK: - Init

    public init(
        businessKey: String,
        invoiceNumber: String,
        title: String,
        description: String? = nil,
        amount: Decimal,
        taxRate: Decimal = 0.0,
        currency: String = "CAD",
        issueDate: Date = .now,
        dueDate: Date
    ) {
        self.businessKey = businessKey
        self.invoiceNumber = invoiceNumber
        self.title = title
        self.invoiceDescription = description
        self.statusRaw = InvoiceStatus.draft.rawValue
        self.amount = amount
        self.taxRate = taxRate
        self.currency = currency
        self.issueDate = issueDate
        self.dueDate = dueDate
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Invoice Status

public enum InvoiceStatus: String, Codable, CaseIterable, Identifiable {
    case draft
    case sent
    case paid
    case overdue
    case cancelled

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .draft: "Draft"
        case .sent: "Sent"
        case .paid: "Paid"
        case .overdue: "Overdue"
        case .cancelled: "Cancelled"
        }
    }
}
