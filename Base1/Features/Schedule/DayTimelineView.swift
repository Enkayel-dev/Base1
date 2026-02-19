//
//  DayTimelineView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI

struct DayTimelineView: View {

    let appointments: [Appointment]
    let activeProjects: [Project]
    let selectedDate: Date
    let isToday: Bool

    // MARK: - Constants

    private let hourHeight: CGFloat = 60
    private let startHour: Int = 0    // 12:00 AM
    private let endHour: Int = 24     // 11:59 PM
    private let hourGutterWidth: CGFloat = 50
    private let projectColumnWidth: CGFloat = 24

    private var gutterWidth: CGFloat {
        if isFutureDay { return hourGutterWidth }
        return hourGutterWidth + CGFloat(activeProjects.count) * projectColumnWidth
    }

    private var totalHours: Int { endHour - startHour }
    private var totalHeight: CGFloat { CGFloat(totalHours) * hourHeight }

    /// Whether the selected date is strictly in the future (after today).
    private var isFutureDay: Bool {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: .now)
        let selectedStart = calendar.startOfDay(for: selectedDate)
        return selectedStart > todayStart
    }

    // MARK: - Scheduled Milestones

    /// Collect schedulable milestones from active projects that fall on the selected day.
    private var scheduledMilestones: [(project: Project, milestone: ProjectMilestone)] {
        let calendar = Calendar.current
        var results: [(Project, ProjectMilestone)] = []
        for project in activeProjects {
            for milestone in project.milestones where milestone.milestoneType.isSchedulable {
                if calendar.isDate(milestone.date, inSameDayAs: selectedDate) {
                    results.append((project, milestone))
                }
            }
        }
        return results
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let eventWidth = geo.size.width - gutterWidth - 8

            ScrollViewReader { proxy in
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        // Hour grid
                        hourGrid

                        // Project Lines (only on today or past days)
                        if !isFutureDay {
                            ForEach(Array(activeProjects.enumerated()), id: \.element.id) { index, project in
                                projectLine(project: project, index: CGFloat(index))
                            }
                        }

                        // Event blocks (appointments + milestone events)
                        let layouts = layoutAllEvents(availableWidth: eventWidth)
                        ForEach(layouts, id: \.id) { item in
                            timelineEventBlock(item: item)
                                .offset(
                                    x: gutterWidth + 4 + item.xOffset,
                                    y: yPosition(for: item.startDate)
                                )
                        }

                        // Now indicator
                        if isToday {
                            nowIndicator
                        }

                        // Scroll anchor
                        let anchorY = isToday ? yPosition(for: .now) : yPosition(forHour: 10)
                        Color.clear
                            .frame(width: 1, height: 1)
                            .id("nowAnchor")
                            .position(x: 0, y: anchorY)
                    }
                    .frame(height: totalHeight)
                    .padding(.bottom, 100)
                }
                .onAppear {
                    proxy.scrollTo("nowAnchor", anchor: .top)
                }
            }
        }
    }

    private func yPosition(forHour hour: Int) -> CGFloat {
        CGFloat(hour - startHour) * hourHeight
    }

    // MARK: - Hour Grid

    private var hourGrid: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0...totalHours, id: \.self) { i in
                let hour = startHour + i
                let y = CGFloat(i) * hourHeight

                HStack(alignment: .top, spacing: 4) {
                    Text(hourLabel(hour))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: hourGutterWidth - 8, alignment: .trailing)

                    Rectangle()
                        .fill(.secondary.opacity(0.2))
                        .frame(height: 0.5)
                        .padding(.top, 6)
                }
                .offset(y: y)
            }
        }
    }

    // MARK: - Project Rendering

    private func projectLine(project: Project, index: CGFloat) -> some View {
        let x = hourGutterWidth + (index * projectColumnWidth) + (projectColumnWidth / 2)

        let calendar = Calendar.current

        let lineStartY: CGFloat = calendar.isDate(project.createdAt, inSameDayAs: selectedDate)
            ? yPosition(for: project.createdAt)
            : 0

        var lineEndY: CGFloat = totalHeight
        if let completedDate = project.completedDate, calendar.isDate(completedDate, inSameDayAs: selectedDate) {
            lineEndY = yPosition(for: completedDate)
        } else if isToday {
            lineEndY = yPosition(for: .now)
        }

        return ZStack(alignment: .topLeading) {
            // Vertical Line
            Rectangle()
                .fill(projectColor(project))
                .frame(width: 4)
                .frame(height: max(0, lineEndY - lineStartY))
                .opacity(0.6)
                .offset(y: lineStartY)

            // Assigned Member segments (Milestones with duration, only past)
            let now = Date.now
            let durationMilestones = project.milestones.filter {
                $0.endDate != nil && calendar.isDate($0.date, inSameDayAs: selectedDate) && $0.date <= now
            }

            ForEach(durationMilestones) { milestone in
                let segmentStartY = yPosition(for: milestone.date)
                let segmentEndY = yPosition(for: milestone.endDate ?? milestone.date)

                Rectangle()
                    .fill(memberColor(milestone.assignedMember))
                    .frame(width: 6)
                    .frame(height: max(0, segmentEndY - segmentStartY))
                    .offset(x: -1, y: segmentStartY)
                    .overlay(alignment: .top) {
                        if let member = milestone.assignedMember {
                            Text(member.initials)
                                .font(.system(size: 6, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.top, 2)
                        }
                    }
            }

            // Milestones for this project that fall on this day (dots — only past milestones)
            let milestonesOnDay = project.milestones.filter {
                calendar.isDate($0.date, inSameDayAs: selectedDate) && $0.date <= now
            }

            ForEach(milestonesOnDay) { milestone in
                milestoneDot(milestone: milestone)
                    .offset(x: -2, y: yPosition(for: milestone.date) - 8)
            }
        }
        .offset(x: x - 2)
    }

    private func milestoneDot(milestone: ProjectMilestone) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)
                .shadow(color: .black.opacity(0.2), radius: 2)
                .overlay {
                    if let member = milestone.assignedMember {
                        Circle()
                            .fill(memberColor(member))
                    } else {
                        Circle()
                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                    }
                }
                .overlay {
                    if let member = milestone.assignedMember {
                        Text(member.initials)
                            .font(.system(size: 4, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

            Text(milestone.milestoneType.displayTitle)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.1), radius: 1)
        }
    }

    private func memberColor(_ member: Member?) -> Color {
        guard let member else { return .secondary }
        switch member.role {
        case .owner: return .blue
        case .admin: return .purple
        case .member: return .gray
        }
    }

    private func projectColor(_ project: Project) -> Color {
        switch project.status {
        case .planning: .blue
        case .inProgress: .green
        case .onHold: .orange
        case .completed: .purple
        case .cancelled: .red
        case .template: .teal
        }
    }

    // MARK: - Now Indicator

    private var nowIndicator: some View {
        let y = yPosition(for: .now)
        return HStack(spacing: 0) {
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
            Rectangle()
                .fill(.red)
                .frame(height: 1)
        }
        .offset(x: hourGutterWidth - 4, y: y - 4)
    }

    // MARK: - Timeline Event Block (Appointment or Milestone)

    @ViewBuilder
    private func timelineEventBlock(item: TimelineLayoutItem) -> some View {
        switch item.source {
        case .appointment(let appt):
            appointmentBlock(appointment: appt, width: item.width, height: item.height)
        case .milestone(let project, let milestone):
            milestoneEventBlock(project: project, milestone: milestone, width: item.width, height: item.height)
        }
    }

    private func appointmentBlock(appointment: Appointment, width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(typeColor(appointment.type).gradient)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(appointment.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if height > 36 {
                    Text(timeText(appointment))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)

            Spacer(minLength: 0)
        }
        .frame(width: width, height: height)
        .background(typeColor(appointment.type).opacity(0.15))
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func milestoneEventBlock(project: Project, milestone: ProjectMilestone, width: CGFloat, height: CGFloat) -> some View {
        let color = milestoneEventColor(milestone.milestoneType)

        return HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color.gradient)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: milestone.milestoneType.systemImage)
                        .font(.system(size: 9))
                    Text(milestone.milestoneType.displayTitle)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }

                Text(project.title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)

            Spacer(minLength: 0)
        }
        .frame(width: width, height: height)
        .background(color.opacity(0.15))
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func milestoneEventColor(_ type: MilestoneType) -> Color {
        switch type {
        case .siteVisit: .orange
        case .materialOrder: .brown
        case .workStarted: .green
        default: .blue
        }
    }

    // MARK: - Unified Layout Algorithm

    /// Source of a timeline event — either an appointment or a scheduled milestone.
    private enum TimelineEventSource {
        case appointment(Appointment)
        case milestone(project: Project, milestone: ProjectMilestone)
    }

    private struct TimelineLayoutItem {
        let id: String
        let source: TimelineEventSource
        let startDate: Date
        let endDate: Date
        let column: Int
        let totalColumns: Int
        let width: CGFloat
        let xOffset: CGFloat

        var height: CGFloat {
            max(CGFloat(endDate.timeIntervalSince(startDate) / 3600.0) * 60, 30)
        }
    }

    private func layoutAllEvents(availableWidth: CGFloat) -> [TimelineLayoutItem] {
        // Build unified event list
        struct RawEvent {
            let id: String
            let source: TimelineEventSource
            let startDate: Date
            let endDate: Date
        }

        var events: [RawEvent] = []

        // Add appointments
        for appt in appointments {
            events.append(RawEvent(
                id: "appt-\(appt.id)",
                source: .appointment(appt),
                startDate: appt.startDate,
                endDate: appt.endDate
            ))
        }

        // Add scheduled milestones
        for (project, milestone) in scheduledMilestones {
            let end = milestone.endDate ?? milestone.date.addingTimeInterval(3600) // default 1hr
            events.append(RawEvent(
                id: "ms-\(milestone.id)",
                source: .milestone(project: project, milestone: milestone),
                startDate: milestone.date,
                endDate: end
            ))
        }

        let sorted = events.sorted { $0.startDate < $1.startDate }
        guard !sorted.isEmpty else { return [] }

        // Greedy column packing
        var columnEnds: [Date] = []
        var assignments: [(event: RawEvent, column: Int)] = []

        for event in sorted {
            var placed = false
            for col in 0..<columnEnds.count {
                if event.startDate >= columnEnds[col] {
                    columnEnds[col] = event.endDate
                    assignments.append((event, col))
                    placed = true
                    break
                }
            }
            if !placed {
                assignments.append((event, columnEnds.count))
                columnEnds.append(event.endDate)
            }
        }

        var results: [TimelineLayoutItem] = []

        for assignment in assignments {
            let overlapping = assignments.filter {
                $0.event.startDate < assignment.event.endDate &&
                $0.event.endDate > assignment.event.startDate
            }
            let colCount = (overlapping.map(\.column).max() ?? 0) + 1

            let eventWidth = availableWidth / CGFloat(colCount)
            let xOff = CGFloat(assignment.column) * eventWidth

            results.append(TimelineLayoutItem(
                id: assignment.event.id,
                source: assignment.event.source,
                startDate: assignment.event.startDate,
                endDate: assignment.event.endDate,
                column: assignment.column,
                totalColumns: colCount,
                width: eventWidth - 2,
                xOffset: xOff
            ))
        }

        return results
    }

    // MARK: - Helpers

    private func yPosition(for date: Date) -> CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let fractionalHour = CGFloat(hour - startHour) + CGFloat(minute) / 60.0
        return fractionalHour * hourHeight
    }

    private func hourLabel(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let suffix = hour < 12 ? "AM" : "PM"
        return "\(h) \(suffix)"
    }

    private func timeText(_ appointment: Appointment) -> String {
        "\(appointment.startDate.formatted(date: .omitted, time: .shortened)) – \(appointment.endDate.formatted(date: .omitted, time: .shortened))"
    }

    private func typeColor(_ type: AppointmentType) -> Color {
        switch type {
        case .consultation: .blue
        case .siteVisit: .orange
        case .meeting: .purple
        case .followUp: .teal
        case .delivery: .green
        }
    }
}
