//
//  AppointmentService.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

@Observable
final class AppointmentService {

    func appointments(
        from all: [Appointment],
        filter: ScheduleFilter
    ) -> [Appointment] {
        switch filter {
        case .all:
            return all
        case .upcoming:
            return all.filter { $0.isUpcoming }
        case .past:
            return all.filter { $0.isPast }
        case .cancelled:
            return all.filter { $0.isCancelled }
        }
    }

    func groupedByDay(_ appointments: [Appointment]) -> [(date: Date, appointments: [Appointment])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: appointments) { appointment in
            calendar.startOfDay(for: appointment.startDate)
        }
        return grouped
            .sorted { $0.key < $1.key }
            .map { (date: $0.key, appointments: $0.value) }
    }
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
