//
//  ProjectMilestone.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-12.
//

import SwiftUI
import SwiftData

@Model
public final class ProjectMilestone {
    public var businessKey: String
    public var milestoneTypeRaw: String
    public var date: Date          // start timestamp
    public var endDate: Date?      // optional end timestamp for duration-based events
    public var notes: String?
    public var createdAt: Date

    // Relationships
    public var project: Project?
    public var assignedMember: Member?

    // Computed
    public var milestoneType: MilestoneType {
        get {
            // Backward compat: old "siteVisitDone" maps to .siteVisit
            if milestoneTypeRaw == "siteVisitDone" { return .siteVisit }
            return MilestoneType(rawValue: milestoneTypeRaw) ?? .created
        }
        set { milestoneTypeRaw = newValue.rawValue }
    }

    /// Duration in hours (max 24h as per timeline logic, but technically unbounded here).
    public var duration: Double {
        guard let endDate else { return 0.0 }
        return endDate.timeIntervalSince(date) / 3600.0
    }

    public init(
        businessKey: String,
        milestoneType: MilestoneType,
        date: Date,
        notes: String? = nil
    ) {
        self.businessKey = businessKey
        self.milestoneTypeRaw = milestoneType.rawValue
        self.date = date
        self.notes = notes
        self.createdAt = .now
    }
}

public enum MilestoneType: String, Codable, CaseIterable, Identifiable {
    case created           // auto — project saved
    case siteVisit         // schedulable — site visit date
    case materialOrder     // schedulable — material order date
    case estimateSent      // auto — PDF generated / locked
    case estimateApproved  // auto milestone — client confirms
    case workStarted       // schedulable — project work date
    case workCompleted     // auto — status → completed
    case invoiceSent       // future — when invoice feature lands
    case invoicePaid       // future

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .created: "Project Created"
        case .siteVisit: "Site Visit"
        case .materialOrder: "Material Order"
        case .estimateSent: "Estimate Sent"
        case .estimateApproved: "Estimate Approved"
        case .workStarted: "Work Started"
        case .workCompleted: "Work Completed"
        case .invoiceSent: "Invoice Sent"
        case .invoicePaid: "Invoice Paid"
        }
    }

    /// Types that appear as schedulable items in Project Detail and as event blocks on the calendar.
    public var isSchedulable: Bool {
        switch self {
        case .siteVisit, .materialOrder, .workStarted: true
        default: false
        }
    }

    public var systemImage: String {
        switch self {
        case .created: "plus.circle.fill"
        case .siteVisit: "camera.fill"
        case .materialOrder: "shippingbox.fill"
        case .estimateSent: "doc.text.fill"
        case .estimateApproved: "checkmark.circle.fill"
        case .workStarted: "hammer.fill"
        case .workCompleted: "flag.checkered.circle.fill"
        case .invoiceSent: "paperplane.fill"
        case .invoicePaid: "dollarsign.circle.fill"
        }
    }
}
