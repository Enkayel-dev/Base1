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
        hourGutterWidth + CGFloat(activeProjects.count) * projectColumnWidth
    }

    private var totalHours: Int { endHour - startHour }
    private var totalHeight: CGFloat { CGFloat(totalHours) * hourHeight }


    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let eventWidth = geo.size.width - gutterWidth - 8

            ScrollViewReader { proxy in
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        // Hour grid
                        hourGrid

                        // Project Lines
                        ForEach(Array(activeProjects.enumerated()), id: \.element.id) { index, project in
                            projectLine(project: project, index: CGFloat(index))
                        }

                        // Event blocks
                        let layouts = layoutEvents(availableWidth: eventWidth)
                        ForEach(layouts, id: \.appointment.id) { item in
                            eventBlock(item: item)
                                .offset(
                                    x: gutterWidth + 4 + item.xOffset,
                                    y: yPosition(for: item.appointment.startDate)
                                )
                        }

                        // Now indicator
                        if isToday {
                            nowIndicator
                        }

                        // Scroll anchor - use layout position instead of offset for reliable proxy scrolling
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
                    // Scroll to current time or morning start, using .top anchor to avoid empty space at 12am
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
        
        // Calculate start/end Y
        let calendar = Calendar.current
        
        // Line Start: If created today, start at creation time. Else start at top.
        let lineStartY: CGFloat = calendar.isDate(project.createdAt, inSameDayAs: selectedDate)
            ? yPosition(for: project.createdAt)
            : 0
            
        // Line End:
        // 1. If completed today, end at completion time.
        // 2. If isToday, end at .now.
        // 3. Otherwise, end at bottom.
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

            // Milestones for this project that fall on this day
            let milestonesOnDay = project.milestones.filter {
                calendar.isDate($0.date, inSameDayAs: selectedDate)
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
                    Circle()
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
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

    private func projectColor(_ project: Project) -> Color {
        // Use status color or job type color if we had one. 
        // For now status color is a good proxy or default to blue.
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

    // MARK: - Event Block

    private func eventBlock(item: LayoutItem) -> some View {
        let height = max(blockHeight(for: item.appointment), 30)

        return HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(typeColor(item.appointment.type).gradient)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.appointment.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if height > 36 {
                    Text(timeText(item.appointment))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)

            Spacer(minLength: 0)
        }
        .frame(width: item.width, height: height)
        .background(typeColor(item.appointment.type).opacity(0.15))
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - Layout Algorithm

    private struct LayoutItem {
        let appointment: Appointment
        let column: Int
        let totalColumns: Int
        let width: CGFloat
        let xOffset: CGFloat
    }

    private func layoutEvents(availableWidth: CGFloat) -> [LayoutItem] {
        let sorted = appointments.sorted { $0.startDate < $1.startDate }
        guard !sorted.isEmpty else { return [] }

        // Assign columns — greedy column packing
        var columnEnds: [Date] = []
        var assignments: [(appointment: Appointment, column: Int)] = []

        for appt in sorted {
            var placed = false
            for col in 0..<columnEnds.count {
                if appt.startDate >= columnEnds[col] {
                    columnEnds[col] = appt.endDate
                    assignments.append((appt, col))
                    placed = true
                    break
                }
            }
            if !placed {
                assignments.append((appt, columnEnds.count))
                columnEnds.append(appt.endDate)
            }
        }

        var results: [LayoutItem] = []

        // Find the actual max columns for each overlap cluster
        for assignment in assignments {
            // Count how many columns are active during this event's time
            let overlapping = assignments.filter {
                $0.appointment.startDate < assignment.appointment.endDate &&
                $0.appointment.endDate > assignment.appointment.startDate
            }
            let colCount = (overlapping.map(\.column).max() ?? 0) + 1

            let eventWidth = availableWidth / CGFloat(colCount)
            let xOff = CGFloat(assignment.column) * eventWidth

            results.append(LayoutItem(
                appointment: assignment.appointment,
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

    private func blockHeight(for appointment: Appointment) -> CGFloat {
        let hours = appointment.duration / 3600
        return CGFloat(hours) * hourHeight
    }

    private func hourLabel(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let suffix = hour < 12 ? "AM" : "PM"
        return "\(h) \(suffix)"
    }

    private func timeText(_ appointment: Appointment) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: appointment.startDate)) – \(formatter.string(from: appointment.endDate))"
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
