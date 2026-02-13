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
    public var date: Date          // exact timestamp
    public var notes: String?
    public var createdAt: Date

    // Relationships
    public var project: Project?

    // Computed
    public var milestoneType: MilestoneType {
        get { MilestoneType(rawValue: milestoneTypeRaw) ?? .created }
        set { milestoneTypeRaw = newValue.rawValue }
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
    case siteVisitDone     // manual — mark site visit complete
    case estimateSent      // auto — PDF generated / locked
    case estimateApproved  // manual — client confirms
    case workStarted       // manual — first day on site
    case workCompleted     // auto — status → completed
    case invoiceSent       // future — when invoice feature lands
    case invoicePaid       // future

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .created: "Project Created"
        case .siteVisitDone: "Site Visit Done"
        case .estimateSent: "Estimate Sent"
        case .estimateApproved: "Estimate Approved"
        case .workStarted: "Work Started"
        case .workCompleted: "Work Completed"
        case .invoiceSent: "Invoice Sent"
        case .invoicePaid: "Invoice Paid"
        }
    }

    public var systemImage: String {
        switch self {
        case .created: "plus.circle.fill"
        case .siteVisitDone: "camera.fill"
        case .estimateSent: "doc.text.fill"
        case .estimateApproved: "checkmark.circle.fill"
        case .workStarted: "hammer.fill"
        case .workCompleted: "flag.checkered.circle.fill"
        case .invoiceSent: "paperplane.fill"
        case .invoicePaid: "dollarsign.circle.fill"
        }
    }
}
