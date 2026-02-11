//
//  AddProjectView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct AddProjectView: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss

    // MARK: - Form Fields

    @State private var selectedClient: Client?
    @State private var selectedJobType: JobType?
    @State private var projectDescription = ""
    @State private var budget = ""

    @State private var hasStartDate = false
    @State private var startDate = Date.now
    @State private var hasDueDate = false
    @State private var dueDate = Date.now.addingTimeInterval(604800)

    @State private var selectedMembers: Set<PersistentIdentifier> = []

    // MARK: - Queries

    @Query(sort: \Client.lastName)
    private var allClients: [Client]

    @Query(sort: \JobType.sortOrder)
    private var allJobTypes: [JobType]

    @Query(sort: \Member.displayName)
    private var allMembers: [Member]

    // MARK: - Computed

    private var autoTitle: String {
        guard let jobType = selectedJobType, let client = selectedClient else { return "" }
        return "\(jobType.name) for \(client.lastName)"
    }

    private var canSave: Bool {
        selectedClient != nil && selectedJobType != nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 24) {
                        clientSection
                        jobTypeSection
                        titlePreview
                        budgetSection
                        dateSection
                        descriptionSection
                        teamSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Add Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveProject() }
                        .disabled(!canSave)
                }
            }
        }
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
    }

    // MARK: - Job Type Section

    private var jobTypeSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Job Type", systemImage: "wrench.and.screwdriver")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if allJobTypes.isEmpty {
                    Text("No job types yet — create them in Business Profile")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Job Type", selection: $selectedJobType) {
                        Text("Select a type…").tag(JobType?.none)
                        ForEach(allJobTypes) { jt in
                            Label(jt.name, systemImage: jt.icon).tag(JobType?.some(jt))
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }

    // MARK: - Title Preview

    @ViewBuilder
    private var titlePreview: some View {
        if canSave {
            sectionCard {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Project Title", systemImage: "text.quote")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(autoTitle)
                        .font(.headline)
                }
            }
        }
    }

    // MARK: - Budget Section

    private var budgetSection: some View {
        sectionCard {
            LabeledTextField("Budget", text: $budget, icon: "dollarsign", keyboardType: .decimalPad)
        }
    }

    // MARK: - Date Section

    private var dateSection: some View {
        sectionCard {
            Toggle(isOn: $hasStartDate) {
                Label("Start Date", systemImage: "calendar")
            }

            if hasStartDate {
                DatePicker("Start", selection: $startDate, displayedComponents: .date)
            }

            Divider()

            Toggle(isOn: $hasDueDate) {
                Label("Due Date", systemImage: "calendar.badge.clock")
            }

            if hasDueDate {
                DatePicker("Due", selection: $dueDate, displayedComponents: .date)
            }
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Description", systemImage: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $projectDescription)
                    .frame(minHeight: 60)
                    .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Team Section

    private var teamSection: some View {
        let acceptedMembers = allMembers.filter { $0.inviteStatus == .accepted || $0.role == .owner }
        return Group {
            if !acceptedMembers.isEmpty {
                sectionCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Assign Team Members", systemImage: "person.3")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ForEach(acceptedMembers) { member in
                            Button {
                                if selectedMembers.contains(member.persistentModelID) {
                                    selectedMembers.remove(member.persistentModelID)
                                } else {
                                    selectedMembers.insert(member.persistentModelID)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: selectedMembers.contains(member.persistentModelID) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(selectedMembers.contains(member.persistentModelID) ? .blue : .secondary)

                                    Text(member.displayName)
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    Text(member.role.displayTitle)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
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
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Save

    private func saveProject() {
        guard let businessKey = businessManager.businessKey,
              let jobType = selectedJobType else { return }

        let project = Project(
            businessKey: businessKey,
            title: autoTitle,
            description: projectDescription.isEmpty ? nil : projectDescription,
            projectType: jobType.name,
            startDate: hasStartDate ? startDate : nil,
            dueDate: hasDueDate ? dueDate : nil
        )

        if let budgetValue = Decimal(string: budget) {
            project.estimatedBudget = budgetValue
        }

        project.client = selectedClient
        project.business = businessManager.currentBusiness

        // Promote lead to active when attached to a project
        if let client = selectedClient, client.status == .lead {
            client.status = .active
            client.updatedAt = .now
        }

        let assigned = allMembers.filter { selectedMembers.contains($0.persistentModelID) }
        project.assignedMembers = assigned

        // Pre-fill scope items from job type template
        for template in jobType.scopeItemTemplates {
            let scopeItem = ScopeItem(
                businessKey: businessKey,
                quantityNeeded: template.defaultQuantity,
                laborHours: template.defaultLaborHours,
                costMarkup: template.defaultCostMarkup,
                description: template.name
            )
            scopeItem.resource = template.resource
            scopeItem.project = project
            modelContext.insert(scopeItem)
        }

        modelContext.insert(project)
        dismiss()
    }
}
