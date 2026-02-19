//
//  AddAppointmentView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

struct AddAppointmentView: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss

    // MARK: - Form Fields

    @State private var selectedClient: Client?
    @State private var selectedProject: Project?
    @State private var appointmentType: AppointmentType = .meeting
    @State private var notes = ""

    @State private var startDate = Date.now.addingTimeInterval(3600)
    @State private var endDate = Date.now.addingTimeInterval(7200)
    @State private var isAllDay = false

    @State private var location = ""

    @State private var reminderMinutes: ReminderOption = .none

    // MARK: - Queries

    @Query(sort: \Client.lastName)
    private var allClients: [Client]

    @Query(sort: \Project.title)
    private var allProjects: [Project]

    private var autoTitle: String {
        guard let client = selectedClient else { return "" }
        return "\(appointmentType.displayTitle) with \(client.lastName)"
    }

    private var canSave: Bool {
        selectedClient != nil
    }

    private var availableProjects: [Project] {
        guard let client = selectedClient else { return [] }
        return allProjects.filter { $0.client?.persistentModelID == client.persistentModelID }
    }

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Add Appointment",
                leadingAction: { dismiss() },
                trailingAction: { saveAppointment() },
                isTrailingDisabled: !canSave
            )

            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 24) {
                        clientSection
                        typeSection
                        titlePreview
                        dateTimeSection
                        locationSection
                        notesSection
                        projectLinkSection
                        reminderSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.clear)
    }

    // MARK: - Client Section

    private var clientSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Client", systemImage: "person")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("Client", selection: $selectedClient) {
                    Text("Select a client…").tag(Client?.none)
                    ForEach(allClients) { client in
                        Text(client.displayName).tag(Client?.some(client))
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .onChange(of: selectedClient) { _, client in
            if let client = client, let address = client.address, location.isEmpty {
                location = address
            }
            selectedProject = nil
        }
    }

    // MARK: - Type Section

    private var typeSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Type", systemImage: "tag")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("Type", selection: $appointmentType) {
                    ForEach(AppointmentType.allCases) { type in
                        Label(type.displayTitle, systemImage: type.systemImage)
                            .tag(type)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    // MARK: - Title Preview

    @ViewBuilder
    private var titlePreview: some View {
        if canSave {
            sectionCard {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Appointment Title", systemImage: "text.quote")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(autoTitle)
                        .font(.headline)
                }
            }
        }
    }

    // MARK: - Date & Time Section

    private var dateTimeSection: some View {
        sectionCard {
            Toggle(isOn: $isAllDay) {
                Label("All Day", systemImage: "sun.max")
            }

            Divider()

            if isAllDay {
                DatePicker("Date", selection: $startDate, displayedComponents: .date)
            } else {
                DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])

                Divider()

                DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
            }
        }
        .onChange(of: isAllDay) { _, allDay in
            if allDay {
                let calendar = Calendar.current
                let start = calendar.startOfDay(for: startDate)
                startDate = start
                endDate = start.addingTimeInterval(86399)
            }
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        sectionCard {
            LabeledTextField("Location", text: $location, icon: "mappin.and.ellipse")
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Notes", systemImage: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $notes)
                    .frame(minHeight: 60)
                    .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Project Link Section

    @ViewBuilder
    private var projectLinkSection: some View {
        if selectedClient != nil && !availableProjects.isEmpty {
            sectionCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Project", systemImage: "folder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("Project", selection: $selectedProject) {
                        Text("None").tag(Project?.none)
                        ForEach(availableProjects) { project in
                            Text(project.title).tag(Project?.some(project))
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }

    // MARK: - Reminder Section

    private var reminderSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Reminder", systemImage: "bell")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("Reminder", selection: $reminderMinutes) {
                    ForEach(ReminderOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    // MARK: - Section Card

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }

    // MARK: - Save

    private func saveAppointment() {
        guard let businessKey = businessManager.businessKey else { return }

        let appointment = Appointment(
            businessKey: businessKey,
            title: autoTitle,
            description: notes.isEmpty ? nil : notes,
            type: appointmentType,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            location: location.isEmpty ? nil : location
        )
        appointment.reminderMinutesBefore = reminderMinutes.minutes
        appointment.client = selectedClient
        appointment.project = selectedProject

        modelContext.insert(appointment)
        dismiss()
    }
}

// MARK: - Reminder Option

private enum ReminderOption: String, CaseIterable, Identifiable {
    case none = "None"
    case fifteenMin = "15 min"
    case thirtyMin = "30 min"
    case oneHour = "1 hour"
    case twoHours = "2 hours"

    var id: String { rawValue }
    var title: String { rawValue }

    var minutes: Int? {
        switch self {
        case .none: nil
        case .fifteenMin: 15
        case .thirtyMin: 30
        case .oneHour: 60
        case .twoHours: 120
        }
    }
}
