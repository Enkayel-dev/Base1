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

    @State private var selectedClientID: PersistentIdentifier?
    @State private var selectedJobTypeID: PersistentIdentifier?
    @State private var projectDescription = ""

    @State private var hasStartDate = false
    @State private var startDate = Date.now
    @State private var hasDueDate = false
    @State private var dueDate = Date.now.addingTimeInterval(604800)

    @State private var selectedMembers: Set<PersistentIdentifier> = []
    
    @State private var isTemplate = false
    @State private var newJobTypeName = ""
    
    // MARK: - Variants
    
    struct VariantDraft: Identifiable {
        let id = UUID()
        var name: String
        var description: String
    }
    
    @State private var variants: [VariantDraft] = []
    @State private var draftVariantName = ""
    @State private var draftVariantDescription = ""

    // MARK: - Queries

    @Query(sort: \Client.lastName)
    private var allClients: [Client]

    @Query(sort: \JobType.sortOrder)
    private var allJobTypes: [JobType]

    @Query(sort: \Member.displayName)
    private var allMembers: [Member]

    // MARK: - Computed

    private var autoTitle: String {
        if isTemplate {
            return newJobTypeName.isEmpty ? "New Template" : newJobTypeName
        }
        guard let jobType = allJobTypes.first(where: { $0.persistentModelID == selectedJobTypeID }),
              let client = allClients.first(where: { $0.persistentModelID == selectedClientID }) else { return "" }
        return "\(jobType.name) for \(client.lastName)"
    }

    private var canSave: Bool {
        if isTemplate {
            return !newJobTypeName.isEmpty
        }
        return selectedClientID != nil && selectedJobTypeID != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Add Project",
                leadingAction: { dismiss() },
                trailingAction: { saveProject() },
                isTrailingDisabled: !canSave
            )

            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 24) {
                        templateToggle
                        
                        if !isTemplate {
                            clientSection
                            jobTypeSection
                            titlePreview
                            dateSection
                            descriptionSection
                            teamSection
                        } else {
                            templateNameSection
                            variantsSection
                            descriptionSection
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.clear)
    }

    private var templateToggle: some View {
        sectionCard {
            Toggle(isOn: $isTemplate) {
                Label("Make Template", systemImage: "square.stack.3d.up")
            }
            .onChange(of: isTemplate) { _, newValue in
                if newValue {
                    selectedClientID = nil
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
                Picker("Client", selection: $selectedClientID) {
                    Text("Select a client…").tag(PersistentIdentifier?.none)
                    ForEach(allClients) { client in
                        Text(client.displayName).tag(PersistentIdentifier?.some(client.persistentModelID))
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedClientID) { _, newValue in
                    if newValue != nil {
                        isTemplate = false
                    }
                }
            }
        }
    }

    // MARK: - Template Name Section
    
    private var templateNameSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 12) {
                LabeledTextField("Job Type Name", text: $newJobTypeName, icon: "hammer")
            }
        }
    }
    // MARK: - Variants Section
    
    private var variantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Variants", systemImage: "square.stack.3d.down.right")
                .font(.headline)
            
            if !variants.isEmpty {
                VStack(spacing: 8) {
                    ForEach(variants) { variant in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(variant.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                if !variant.description.isEmpty {
                                    Text(variant.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Button {
                                variants.removeAll { $0.id == variant.id }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            
            sectionCard {
                VStack(spacing: 12) {
                    LabeledTextField("Variant Name", text: $draftVariantName, icon: "tag")
                    LabeledTextField("Variant Description", text: $draftVariantDescription, icon: "text.alignleft")
                    
                    Button {
                        variants.append(VariantDraft(name: draftVariantName, description: draftVariantDescription))
                        draftVariantName = ""
                        draftVariantDescription = ""
                    } label: {
                        Label("Add Variant", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(draftVariantName.isEmpty)
                }
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
                    Picker("Job Type", selection: $selectedJobTypeID) {
                        Text("Select a type…").tag(PersistentIdentifier?.none)
                        ForEach(allJobTypes) { jt in
                            Label(jt.name, systemImage: jt.icon).tag(PersistentIdentifier?.some(jt.persistentModelID))
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
        guard let businessKey = businessManager.businessKey else { return }

        if isTemplate {
            // 1. Create Parent JobType
            let parentJobType = JobType(
                businessKey: businessKey,
                name: newJobTypeName,
                parent: nil
            )
            parentJobType.business = businessManager.currentBusiness
            modelContext.insert(parentJobType)
            
            // 2. Create Parent Template Project (Masters Scope)
            let parentProject = Project(
                businessKey: businessKey,
                title: newJobTypeName,
                description: projectDescription.isEmpty ? nil : projectDescription,
                status: .template
            )
            parentProject.jobType = parentJobType
            parentProject.business = businessManager.currentBusiness
            modelContext.insert(parentProject)
            
            // 3. Create Variants
            for varDraft in variants {
                let variantJobType = JobType(
                    businessKey: businessKey,
                    name: varDraft.name,
                    variantDescription: varDraft.description.isEmpty ? nil : varDraft.description,
                    parent: parentJobType
                )
                variantJobType.business = businessManager.currentBusiness
                modelContext.insert(variantJobType)
                
                let variantProject = Project(
                    businessKey: businessKey,
                    title: varDraft.name,
                    description: varDraft.description.isEmpty ? nil : varDraft.description,
                    status: .template
                )
                variantProject.jobType = variantJobType
                variantProject.business = businessManager.currentBusiness
                modelContext.insert(variantProject)
            }
            
        } else {
            // Regular Project Creation
            let project = Project(
                businessKey: businessKey,
                title: autoTitle,
                description: projectDescription.isEmpty ? nil : projectDescription,
                status: .planning,
                startDate: hasStartDate ? startDate : nil,
                dueDate: hasDueDate ? dueDate : nil
            )

            project.client = allClients.first { $0.persistentModelID == selectedClientID }
            project.business = businessManager.currentBusiness

            if let templateJobType = allJobTypes.first(where: { $0.persistentModelID == selectedJobTypeID }) {
                project.jobType = templateJobType
                
                // Deep Duplication from Template
                if let templateProject = templateJobType.templateProject {
                    let service = ProjectService(modelContext: modelContext)
                    service.duplicateTemplate(from: templateProject, to: project)
                }
            }

            // Promote lead to active
            if let clientID = selectedClientID,
               let client = allClients.first(where: { $0.persistentModelID == clientID }),
               client.status == .lead {
                client.status = .active
                client.updatedAt = .now
            }

            let assigned = allMembers.filter { selectedMembers.contains($0.persistentModelID) }
            project.assignedMembers = assigned

            modelContext.insert(project)
        }

        dismiss()
    }
}
