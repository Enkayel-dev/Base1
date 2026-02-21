//
//  AppointmentService.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import Foundation

// MARK: - Appointment Filtering

func filteredAppointments(_ all: [Appointment], filter: ScheduleFilter) -> [Appointment] {
    switch filter {
    case .all:          return all
    case .upcoming:     return all.filter { $0.isUpcoming }
    case .past:         return all.filter { $0.isPast }
    case .cancelled:    return all.filter { $0.isCancelled }
    }
}

func appointmentsGroupedByDay(_ appointments: [Appointment]) -> [(date: Date, appointments: [Appointment])] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: appointments) { calendar.startOfDay(for: $0.startDate) }
    return grouped
        .sorted { $0.key < $1.key }
        .map { (date: $0.key, appointments: $0.value) }
}

// MARK: - Schedule Filter

enum ScheduleFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case upcoming = "Upcoming"
    case past = "Past"
    case cancelled = "Cancelled"

    var id: String { rawValue }
    var title: String { rawValue }
}
