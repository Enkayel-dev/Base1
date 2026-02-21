//
//  ProjectDetailView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProjectDetailView: View {
    let project: Project

    @Environment(DrawerRouter.self) private var drawerRouter
    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss

    // MARK: - Inline Form State
    @State private var isAddingMeasurement = false
    @State private var isAddingPhoto = false
    
    // Measurement form fields
    @State private var measurementName = ""
    @State private var measurementValue = ""
    @State private var measurementUnit: UnitOfMeasure = .sqft
    @State private var measurementNotes = ""
    
    // Photo form fields
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoImageData: Data?
    @State private var photoCaption = ""

    private var sortedMeasurements: [ProjectMeasurement] {
        project.measurements.sorted { $0.createdAt > $1.createdAt }
    }

    private var sortedScopeItems: [ScopeItem] {
        project.scopeItems.sorted { $0.createdAt > $1.createdAt }
    }

    private var sortedPhotos: [ProjectPhoto] {
        project.photos.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Whether the current user can add photos to this project.
    /// True if: not locked, OR user is assigned staff on an in-progress project.
    private var canAddPhotos: Bool {
        // Always allow when not locked
        if !project.isLocked { return true }
        
        // When locked, allow assigned staff to add progress photos
        guard let currentMember = businessManager.currentMember else { return false }
        
        // Check if current member is assigned to any scope item or milestone
        let isAssignedToProject = project.teamMembers.contains {
            $0.persistentModelID == currentMember.persistentModelID
        }
        
        return isAssignedToProject && project.status == .inProgress
    }

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: project.title,
                leadingText: "Back",
                leadingAction: {
                    if project.status == .template, let jt = project.jobType, jt.parent == nil {
                        let service = ProjectService(modelContext: modelContext)
                        service.syncScopeFromParentToVariants(parentTemplateProject: project)
                    }
                    dismiss()
                },
                trailingText: nil,
                trailingAction: nil
            )

            ScrollView {
                VStack(spacing: 24) {
                    projectHeader
                    clientSection
                    measurementsSection
                    scopeItemsSection
                    scheduleSection
                    photosSection
                    documentsSection
                    summarySection
                }
                .padding()
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
    }

    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Documents")
                .font(.headline)

            if !project.isLocked {
                Text("No documents generated yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        Button {
                            drawerRouter.present(.projectEstimate(project.persistentModelID))
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.blue)
                                
                                Text("Project Estimate")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                
                                Text(project.updatedAt, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(width: 140, height: 140, alignment: .topLeading)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                        }
                    }
                }
                .scrollIndicators(.never)
            }
        }
    }

    // MARK: - Project Header

    private var projectHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(project.status.displayTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(statusColor.gradient)
                    .clipShape(Capsule())

                Spacer()

                if let jobType = project.jobType {
                    Text(jobType.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let description = project.projectDescription {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            // Project Notes (Contract Terms)
            projectNotesSection
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }
    
    // MARK: - Project Notes Section
    
    @ViewBuilder
    private var projectNotesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Project Notes", systemImage: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if !project.isLocked {
                    Text("Appears on estimate")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            if project.isLocked {
                // Read-only when locked
                if let notes = project.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No project notes")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            } else {
                // Editable when not locked
                @Bindable var editableProject = project
                TextField("Add project-specific terms, conditions, or notes...", text: $editableProject.notes.orEmpty, axis: .vertical)
                    .font(.subheadline)
                    .lineLimit(3...6)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Client Section

    private var clientSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Client")
                .font(.headline)

            if let client = project.client {
                Button {
                    drawerRouter.present(.clientDetail(client.persistentModelID))
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(.blue.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text(client.initials)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(client.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            if let company = client.companyName {
                                Text(company)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                }
            } else {
                Text("No client linked")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            }
        }
    }

    // MARK: - Team Section (Derived)

    @ViewBuilder
    private var teamSection: some View {
        let members = project.teamMembers
        if !members.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Assigned Team")
                    .font(.headline)

                VStack(spacing: 0) {
                    ForEach(members) { member in
                        MemberRowView(member: member)
                        if member.id != members.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            }
        }
    }

    // MARK: - Schedule Section

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project Schedule")
                .font(.headline)

            VStack(spacing: 8) {
                // Schedulable milestones
                let displayTypes: [MilestoneType] = [.siteVisit, .materialOrder, .workStarted]

                ForEach(displayTypes) { type in
                    milestoneScheduleRow(type: type)
                }
            }
        }
    }

    private func milestoneScheduleRow(type: MilestoneType) -> some View {
        let milestone = project.milestones.first { $0.milestoneType == type }
        
        return Button {
            drawerRouter.present(.addSchedule(project.persistentModelID, type))
        } label: {
            HStack(spacing: 12) {
                Image(systemName: type.systemImage)
                    .font(.title3)
                    .foregroundStyle(milestone != nil ? .blue : .secondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(type == .workStarted ? "Project Work" : type.displayTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    if let milestone {
                        HStack(spacing: 4) {
                            if let member = milestone.assignedMember {
                                Text(member.displayName)
                                    .fontWeight(.semibold)
                            }
                            Text("Scheduled for \(milestone.date, style: .date)")
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    } else {
                        Text("Not scheduled")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if milestone != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Measurements Section

    private var measurementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Measurements")
                    .font(.headline)
                Spacer()
                if !project.isLocked && !isAddingMeasurement {
                    Button {
                        withAnimation(.spring(
                            response: DesignConstants.Animation.morphResponse,
                            dampingFraction: DesignConstants.Animation.morphDamping
                        )) {
                            isAddingMeasurement = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }

            // Inline add measurement form
            if !project.isLocked && isAddingMeasurement {
                inlineMeasurementForm
            }

            if project.measurements.isEmpty && !isAddingMeasurement {
                Text("No measurements recorded")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            } else if !project.measurements.isEmpty {
                VStack(spacing: 8) {
                    ForEach(sortedMeasurements) { m in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(m.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                if let notes = m.notes {
                                    Text(notes)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Text("\(m.value as NSDecimalNumber) \(m.unit.abbreviation)")
                                .font(.subheadline)
                                .monospacedDigit()
                        }
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                    }
                }
            }
        }
    }
    
    // MARK: - Inline Measurement Form
    
    private var inlineMeasurementForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with cancel/save
            HStack {
                Button("Cancel") {
                    withAnimation(.spring(
                        response: DesignConstants.Animation.morphResponse,
                        dampingFraction: DesignConstants.Animation.morphDamping
                    )) {
                        resetMeasurementForm()
                        isAddingMeasurement = false
                    }
                }
                .font(.subheadline)
                
                Spacer()
                
                Button("Save") {
                    saveMeasurement()
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .disabled(measurementName.isEmpty || measurementValue.isEmpty)
            }
            
            Divider()
            
            // Form fields
            VStack(alignment: .leading, spacing: 12) {
                LabeledTextField("Name", text: $measurementName, icon: "tag")
                Text("e.g., Front Deck, Kitchen Floor")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                LabeledTextField("Value", text: $measurementValue, icon: "number", keyboardType: .decimalPad)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unit")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("Unit", selection: $measurementUnit) {
                        ForEach(UnitOfMeasure.grouped().filter {
                            $0.category == .area || $0.category == .length || $0.category == .volume
                        }, id: \.category) { group in
                            Section(group.category.displayTitle) {
                                ForEach(group.units) { unit in
                                    Text(unit.displayTitle).tag(unit)
                                }
                            }
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Notes", systemImage: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Optional notes...", text: $measurementNotes, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }
    
    private func saveMeasurement() {
        guard let businessKey = businessManager.businessKey,
              let val = Decimal(string: measurementValue) else { return }
        
        let measurement = ProjectMeasurement(
            businessKey: businessKey,
            name: measurementName,
            value: val,
            unit: measurementUnit,
            notes: measurementNotes.isEmpty ? nil : measurementNotes
        )
        measurement.project = project
        modelContext.insert(measurement)
        
        withAnimation(.spring(
            response: DesignConstants.Animation.morphResponse,
            dampingFraction: DesignConstants.Animation.morphDamping
        )) {
            resetMeasurementForm()
            isAddingMeasurement = false
        }
    }
    
    private func resetMeasurementForm() {
        measurementName = ""
        measurementValue = ""
        measurementUnit = .sqft
        measurementNotes = ""
    }

    // MARK: - Scope Items Section

    private var scopeItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scope Items")
                    .font(.headline)

                Spacer()

                if !project.isLocked {
                    Button {
                        drawerRouter.present(.addScopeItem(project.persistentModelID))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }

            if project.scopeItems.isEmpty {
                Text("No scope items yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            } else {
                ForEach(sortedScopeItems) { item in
                    ScopeItemRowView(scopeItem: item)
                }
            }
        }
    }

    // MARK: - Site Photos Section

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Site Photos")
                    .font(.headline)
                Spacer()
                // Allow adding photos:
                // - When not locked (planning phase)
                // - When locked and user is assigned staff (for progress photos)
                if canAddPhotos && !isAddingPhoto {
                    Button {
                        withAnimation(.spring(
                            response: DesignConstants.Animation.morphResponse,
                            dampingFraction: DesignConstants.Animation.morphDamping
                        )) {
                            isAddingPhoto = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }

            // Inline add photo form
            if !project.isLocked && isAddingPhoto {
                inlinePhotoForm
            }

            if project.photos.isEmpty && !isAddingPhoto {
                Text("No photos uploaded")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            } else if !project.photos.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(sortedPhotos) { photo in
                            if let data = photo.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                            }
                        }
                    }
                }
                .scrollIndicators(.never)
            }
        }
    }
    
    // MARK: - Inline Photo Form
    
    private var inlinePhotoForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with cancel/save
            HStack {
                Button("Cancel") {
                    withAnimation(.spring(
                        response: DesignConstants.Animation.morphResponse,
                        dampingFraction: DesignConstants.Animation.morphDamping
                    )) {
                        resetPhotoForm()
                        isAddingPhoto = false
                    }
                }
                .font(.subheadline)
                
                Spacer()
                
                Button("Save") {
                    savePhoto()
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .disabled(photoImageData == nil)
            }
            
            Divider()
            
            // Photo picker or preview
            if let imageData = photoImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            photoImageData = nil
                            selectedPhotoItem = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white, .black.opacity(0.5))
                                .font(.title2)
                                .padding(8)
                        }
                    }
            } else {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 32))
                        Text("Select Photo")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius)
                            .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    }
                }
            }
            
            // Caption
            VStack(alignment: .leading, spacing: 8) {
                Label("Caption", systemImage: "text.alignleft")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Optional description...", text: $photoCaption)
                    .textFieldStyle(.plain)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    photoImageData = data
                }
            }
        }
    }
    
    private func savePhoto() {
        guard let businessKey = businessManager.businessKey,
              let data = photoImageData else { return }
        
        let photo = ProjectPhoto(
            businessKey: businessKey,
            imageData: data,
            caption: photoCaption.isEmpty ? nil : photoCaption
        )
        photo.project = project
        modelContext.insert(photo)
        
        withAnimation(.spring(
            response: DesignConstants.Animation.morphResponse,
            dampingFraction: DesignConstants.Animation.morphDamping
        )) {
            resetPhotoForm()
            isAddingPhoto = false
        }
    }
    
    private func resetPhotoForm() {
        selectedPhotoItem = nil
        photoImageData = nil
        photoCaption = ""
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                summaryCard(
                    title: "Total Cost",
                    value: formatCurrency(project.totalScopeCost),
                    icon: "dollarsign.circle"
                )

                summaryCard(
                    title: "Labor Hours",
                    value: "\(project.totalLaborHours as NSDecimalNumber)h",
                    icon: "clock"
                )
            }

            HStack(spacing: 12) {
                summaryCard(
                    title: "Materials",
                    value: formatCurrency(project.totalMaterialCost),
                    icon: "shippingbox"
                )

                summaryCard(
                    title: "Labor",
                    value: formatCurrency(project.totalLaborCost),
                    icon: "person"
                )
            }

            // Fixed Cost (project-level)
            if !project.isLocked {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Fixed Costs", systemImage: "dollarsign")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0.00", value: Binding(
                        get: { project.fixedCost ?? Decimal.zero },
                        set: { project.fixedCost = $0 > 0 ? $0 : nil }
                    ), format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
                    .font(.title3)
                    .fontWeight(.semibold)

                    Text("For permits, subcontractor quotes, disposal fees, etc.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            } else if project.totalFixedCost > 0 {
                summaryCard(
                    title: "Fixed Costs",
                    value: formatCurrency(project.totalFixedCost),
                    icon: "dollarsign"
                )
            }

            if project.hasInventoryIssues {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Some scope items need additional inventory")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            }

            // MARK: Team section moved here to be part of the summary flow
            teamSection

            if project.status == .planning && !project.isLocked {
                let isValid = project.client != nil && !project.scopeItems.isEmpty && !project.measurements.isEmpty
                
                Button {
                    lockInProject()
                } label: {
                    HStack {
                        Spacer()
                        if isValid {
                            Image(systemName: "lock.fill")
                        } else {
                            Image(systemName: "exclamationmark.triangle")
                        }
                        Text("Lock in & Prepare Estimate")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    .background(isValid ? Color.blue : Color.secondary.opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                }
                .disabled(!isValid)
                
                if !isValid {
                    Text("Requires Client, Measurement, and Scope Item")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func lockInProject() {
        project.status = .inProgress
        project.isLocked = true
        project.updatedAt = .now
        
        // Create milestone
        if let businessKey = project.business?.businessKey {
            let milestone = ProjectMilestone(
                businessKey: businessKey,
                milestoneType: .estimateSent,
                date: .now
            )
            milestone.project = project
            modelContext.insert(milestone)
        }
    }

    private func summaryCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }

    // MARK: - Helpers

    private var statusColor: Color {
        switch project.status {
        case .planning: .blue
        case .inProgress: .green
        case .onHold: .orange
        case .completed: .purple
        case .cancelled: .red
        case .template: .teal
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
}
