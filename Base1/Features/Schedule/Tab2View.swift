//
//  Tab2View.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI
import SwiftData

struct Tab2View: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(DrawerRouter.self) private var drawerRouter
    @State private var selectedDate = Date.now

    @Query(sort: \Appointment.startDate)
    private var allAppointments: [Appointment]

    @Query(sort: \Project.createdAt)
    private var allProjects: [Project]

    // MARK: - Business Scope

    private var businessAppointments: [Appointment] {
        guard let key = businessManager.businessKey else { return [] }
        return allAppointments.filter { $0.businessKey == key }
    }

    private var businessProjects: [Project] {
        guard let key = businessManager.businessKey else { return [] }
        return allProjects.filter { $0.businessKey == key }
    }

    // MARK: - Selected Day Filtering

    private var activeProjectsForDay: [Project] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return businessProjects.filter { project in
            // Project is active if:
            // 1. Created on or before selected date (end of day)
            // 2. AND (Not completed OR completed on or after start of selected date)
            // 3. AND Status is not cancelled or template
            let isCreatedBeforeOrOnDay = project.createdAt < endOfDay
            let isNotCompletedOrCompletedAfterStart = project.completedDate == nil || project.completedDate! >= startOfDay
            let isValidStatus = project.status != .cancelled && project.status != .template

            return isCreatedBeforeOrOnDay && isNotCompletedOrCompletedAfterStart && isValidStatus
        }
    }

    private var selectedDayAppointments: [Appointment] {
        businessAppointments.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate)
        }
    }

    private var timedAppointments: [Appointment] {
        selectedDayAppointments.filter { !$0.isAllDay }
    }

    private var allDayAppointments: [Appointment] {
        selectedDayAppointments.filter { $0.isAllDay }
    }

    private var isSelectedDateToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            header
            dateSelector
            allDayBanner

            if timedAppointments.isEmpty && allDayAppointments.isEmpty && activeProjectsForDay.isEmpty {
                EmptyScheduleView()
                    .frame(maxHeight: .infinity, alignment: .top)
            } else {
                DayTimelineView(
                    appointments: timedAppointments,
                    activeProjects: activeProjectsForDay,
                    selectedDate: selectedDate,
                    isToday: isSelectedDateToday
                )
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Text("Schedule")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Button {
                drawerRouter.present(.addAppointment)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Date Selector

    private var dateSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(dateRange, id: \.self) { date in
                        datePill(date)
                            .id(date)
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                let today = Calendar.current.startOfDay(for: .now)
                proxy.scrollTo(today, anchor: .center)
            }
        }
        .padding(.bottom, 8)
    }

    private var dateRange: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (-7...14).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }

    private func datePill(_ date: Date) -> some View {
        let calendar = Calendar.current
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 2) {
                Text(dayOfWeek(date))
                    .font(.caption2)
                    .fontWeight(.medium)

                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.callout)
                    .fontWeight(isToday ? .bold : .regular)
            }
            .foregroundStyle(isSelected ? .white : .secondary)
            .frame(width: 40, height: 48)
            .background(
                isSelected
                    ? AnyShapeStyle(.white.opacity(0.25))
                    : AnyShapeStyle(.clear)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isToday && !isSelected ? .white.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
    }

    private func dayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    // MARK: - All Day Banner

    @ViewBuilder
    private var allDayBanner: some View {
        if !allDayAppointments.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allDayAppointments) { appt in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(allDayColor(appt.type).gradient)
                                .frame(width: 8, height: 8)
                            Text(appt.title)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 4)
        }
    }

    private func allDayColor(_ type: AppointmentType) -> Color {
        switch type {
        case .consultation: .blue
        case .siteVisit: .orange
        case .meeting: .purple
        case .followUp: .teal
        case .delivery: .green
        }
    }
}
