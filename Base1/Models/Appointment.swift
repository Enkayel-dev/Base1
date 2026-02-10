//
//  Appointment.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

@Model
public final class Appointment {

    // MARK: - Fields

    public var title: String
    public var appointmentDescription: String?
    public var typeRaw: String
    public var startDate: Date
    public var endDate: Date
    public var isAllDay: Bool
    public var location: String?
    public var notes: String?
    public var isCompleted: Bool
    public var isCancelled: Bool
    public var reminderMinutesBefore: Int?

    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    public var client: Client?
    public var project: Project?

    // MARK: - Computed

    public var type: AppointmentType {
        get { AppointmentType(rawValue: typeRaw) ?? .meeting }
        set { typeRaw = newValue.rawValue }
    }

    public var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    public var isUpcoming: Bool {
        !isCompleted && !isCancelled && startDate > .now
    }

    public var isPast: Bool {
        endDate < .now
    }

    // MARK: - Init

    public init(
        title: String,
        description: String? = nil,
        type: AppointmentType = .meeting,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        location: String? = nil
    ) {
        self.title = title
        self.appointmentDescription = description
        self.typeRaw = type.rawValue
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.location = location
        self.isCompleted = false
        self.isCancelled = false
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Appointment Type

public enum AppointmentType: String, Codable, CaseIterable, Identifiable {
    case consultation
    case siteVisit
    case meeting
    case followUp
    case delivery

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .consultation: "Consultation"
        case .siteVisit: "Site Visit"
        case .meeting: "Meeting"
        case .followUp: "Follow-Up"
        case .delivery: "Delivery"
        }
    }

    public var systemImage: String {
        switch self {
        case .consultation: "person.2"
        case .siteVisit: "location"
        case .meeting: "calendar"
        case .followUp: "arrow.uturn.left"
        case .delivery: "shippingbox"
        }
    }
}
