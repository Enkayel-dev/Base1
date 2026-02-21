//
//  AddScopeItemTemplateView.swift
//  Base1
//
//  Created by Claude on 2026-02-19.
//

import SwiftUI
import SwiftData

struct AddScopeItemTemplateView: View {
    /// Pass nil for add mode, pass existing template for edit mode
    let template: ScopeItemTemplate?
    
    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss
    
    @Query(sort: \Resource.name) private var allResources: [Resource]
    @Query(sort: \JobType.sortOrder) private var allJobTypes: [JobType]
    
    // Form state
    @State private var name = ""
    @State private var selectedResourceID: PersistentIdentifier?
    @State private var selectedJobTypeID: PersistentIdentifier?
    @State private var defaultQuantity = "1"
    @State private var defaultUnit: UnitOfMeasure = .each
    @State private var defaultLaborHours = ""
    @State private var notes = ""
    
    private var isEditMode: Bool { template != nil }
    
    private var canSave: Bool {
        !name.isEmpty && selectedResourceID != nil
    }
    
    private var businessResources: [Resource] {
        guard let key = businessManager.businessKey else { return [] }
        return allResources.filter { $0.businessKey == key && $0.category == .material }
    }
    
    private var businessJobTypes: [JobType] {
        guard let key = businessManager.businessKey else { return [] }
        return allJobTypes.filter { $0.businessKey == key && $0.parent == nil }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: isEditMode ? "Edit Template" : "New Template",
                leadingAction: { dismiss() },
                trailingAction: { save() },
                isTrailingDisabled: !canSave
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Name
                    sectionCard {
                        LabeledTextField("Template Name", text: $name, icon: "tag")
                        Text("A descriptive name for this scope item template")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Resource
                    sectionCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Resource", systemImage: "cube.box")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Picker("Resource", selection: $selectedResourceID) {
                                Text("Select Resource").tag(PersistentIdentifier?.none)
                                ForEach(businessResources) { resource in
                                    Text(resource.name).tag(PersistentIdentifier?.some(resource.persistentModelID))
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    
                    // Job Type
                    sectionCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Job Type", systemImage: "folder")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Picker("Job Type", selection: $selectedJobTypeID) {
                                Text("Any Job Type").tag(PersistentIdentifier?.none)
                                ForEach(businessJobTypes) { jobType in
                                    Text(jobType.name).tag(PersistentIdentifier?.some(jobType.persistentModelID))
                                }
                            }
                            .pickerStyle(.menu)
                            
                            Text("Optionally limit this template to a specific job type")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Default Values
                    sectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Default Values", systemImage: "slider.horizontal.3")
                                .font(.headline)
                            
                            HStack(spacing: 12) {
                                LabeledTextField("Quantity", text: $defaultQuantity, icon: "number", keyboardType: .decimalPad)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Unit")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Picker("Unit", selection: $defaultUnit) {
                                        ForEach(UnitOfMeasure.allCases) { unit in
                                            Text(unit.displayTitle).tag(unit)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            LabeledTextField("Labor Hours", text: $defaultLaborHours, icon: "clock", keyboardType: .decimalPad)
                        }
                    }
                    
                    // Notes
                    sectionCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Notes", systemImage: "note.text")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            TextField("Default notes for this item...", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                            
                            Text("These notes will appear on the estimate when using this template")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Delete button (edit mode only)
                    if isEditMode {
                        Button(role: .destructive) {
                            deleteTemplate()
                        } label: {
                            Label("Delete Template", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
        .onAppear {
            loadTemplateData()
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
    
    // MARK: - Actions
    
    private func loadTemplateData() {
        guard let template else { return }
        
        name = template.name
        selectedResourceID = template.resource?.persistentModelID
        selectedJobTypeID = template.jobType?.persistentModelID
        defaultQuantity = "\(template.defaultQuantity)"
        defaultUnit = template.defaultUnit ?? .each
        if let hours = template.defaultLaborHours {
            defaultLaborHours = "\(hours)"
        }
        notes = template.notes ?? ""
    }
    
    private func save() {
        guard let businessKey = businessManager.businessKey,
              let qty = Decimal(string: defaultQuantity) else { return }
        
        let hours = Decimal(string: defaultLaborHours)
        
        if let existing = template {
            // Update existing
            existing.name = name
            existing.defaultQuantity = qty
            existing.defaultUnit = defaultUnit
            existing.defaultLaborHours = hours
            existing.notes = notes.isEmpty ? nil : notes
            
            // Update resource
            if let resourceID = selectedResourceID {
                existing.resource = modelContext.registeredModel(for: resourceID) as Resource?
            } else {
                existing.resource = nil
            }
            
            // Update job type
            if let jobTypeID = selectedJobTypeID {
                existing.jobType = modelContext.registeredModel(for: jobTypeID) as JobType?
            } else {
                existing.jobType = nil
            }
        } else {
            // Create new
            let newTemplate = ScopeItemTemplate(
                businessKey: businessKey,
                name: name,
                defaultQuantity: qty,
                defaultLaborHours: hours,
                defaultUnit: defaultUnit
            )
            newTemplate.notes = notes.isEmpty ? nil : notes
            newTemplate.business = businessManager.currentBusiness
            
            // Set resource
            if let resourceID = selectedResourceID {
                newTemplate.resource = modelContext.registeredModel(for: resourceID) as Resource?
            }
            
            // Set job type
            if let jobTypeID = selectedJobTypeID {
                newTemplate.jobType = modelContext.registeredModel(for: jobTypeID) as JobType?
            }
            
            modelContext.insert(newTemplate)
        }
        
        dismiss()
    }
    
    private func deleteTemplate() {
        guard let template else { return }
        modelContext.delete(template)
        dismiss()
    }
}
