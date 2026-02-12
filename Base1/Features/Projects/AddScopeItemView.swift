//
//  AddScopeItemView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct AddScopeItemView: View {
    let project: Project

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss

    // MARK: - Form Fields

    @State private var itemDescription = ""
    @State private var laborHours = ""
    @State private var fixedCost = ""
    @State private var costMarkup = ""
    @State private var status: ScopeItemStatus = .pending
    @State private var notes = ""
    @State private var selectedMember: Member?

    // MARK: - Resource Entries

    @State private var resourceEntries: [ResourceEntry] = []
    @State private var pendingResource: Resource?
    @State private var pendingQuantity = ""
    @State private var pendingUnit: UnitOfMeasure = .each

    // MARK: - Queries

    @Query(sort: \Resource.name)
    private var allResources: [Resource]

    @Query(sort: \Member.displayName)
    private var allMembers: [Member]

    private var businessResources: [Resource] {
        guard let key = businessManager.businessKey else { return [] }
        return allResources.filter { $0.businessKey == key }
    }

    private var businessMembers: [Member] {
        guard let key = businessManager.businessKey else { return [] }
        return allMembers.filter { $0.businessKey == key }
    }

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Add Scope Item",
                leadingAction: { dismiss() },
                trailingAction: { saveScopeItem() },
                isTrailingDisabled: !canSave
            )

            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 24) {
                        descriptionSection
                        resourcesSection
                        laborSection
                        fixedCostSection
                        costSection
                        detailsSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.clear)
    }

    private var canSave: Bool {
        !itemDescription.isEmpty || !resourceEntries.isEmpty || !fixedCost.isEmpty || !laborHours.isEmpty
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Description", systemImage: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $itemDescription)
                    .frame(minHeight: 60)
                    .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Resources Section

    private var resourcesSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Resources", systemImage: "shippingbox")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Existing entries
                ForEach(resourceEntries.indices, id: \.self) { index in
                    let entry = resourceEntries[index]
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.resource.name)
                                .font(.subheadline)
                            Text("\(entry.quantity as NSDecimalNumber) \(entry.unit.abbreviation)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let unitCost = entry.resource.unitCost {
                                Text("Cost: \(formatCurrency(entry.quantity * unitCost))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Button {
                            resourceEntries.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }

                    if index < resourceEntries.count - 1 {
                        Divider()
                    }
                }

                if !resourceEntries.isEmpty {
                    Divider()
                }

                // Add resource row
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Resource", selection: $pendingResource) {
                        Text("Select Resource").tag(Resource?.none)
                        ForEach(businessResources) { resource in
                            Label(resource.name, systemImage: resource.category.systemImage)
                                .tag(Resource?.some(resource))
                        }
                    }
                    .pickerStyle(.menu)

                    if pendingResource != nil {
                        HStack(spacing: 12) {
                            LabeledTextField("Qty", text: $pendingQuantity, icon: "number", keyboardType: .decimalPad)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Unit")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Picker("Unit", selection: $pendingUnit) {
                                    ForEach(UnitOfMeasure.grouped(), id: \.category) { group in
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

                        Button {
                            addResourceEntry()
                        } label: {
                            Label("Add Resource", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                        }
                        .disabled(pendingQuantity.isEmpty)
                    }
                }

                if let res = pendingResource {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Available: \(res.availableQuantity as NSDecimalNumber) \(res.unit.abbreviation)")
                            .font(.caption)
                            .foregroundStyle(res.availableQuantity > 0 ? Color.secondary : Color.orange)
                        if let cost = res.unitCost {
                            Text("Unit Cost: \(formatCurrency(cost))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    // MARK: - Labor Section

    private var laborSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Labor", systemImage: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Assigned Member", selection: $selectedMember) {
                    Text("None").tag(Member?.none)
                    ForEach(businessMembers) { member in
                        HStack {
                            Text(member.displayName)
                            if let rate = member.hourlyRate {
                                Text("(\(formatCurrency(rate))/hr)")
                            }
                        }
                        .tag(Member?.some(member))
                    }
                }
                .pickerStyle(.menu)
            }

            Divider()

            LabeledTextField("Labor Hours", text: $laborHours, icon: "clock", keyboardType: .decimalPad)

            if let hours = Decimal(string: laborHours),
               let rate = selectedMember?.hourlyRate {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Labor Cost", systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatCurrency(hours * rate))
                        .font(.headline)
                }
            }
        }
    }

    // MARK: - Fixed Cost Section

    private var fixedCostSection: some View {
        sectionCard {
            LabeledTextField("Fixed Cost", text: $fixedCost, icon: "dollarsign", keyboardType: .decimalPad)

            Text("For permits, subcontractor quotes, disposal fees, etc.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Cost Section

    private var costSection: some View {
        sectionCard {
            LabeledTextField("Cost Markup (%)", text: $costMarkup, icon: "percent", keyboardType: .decimalPad)

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Label("Estimated Total", systemImage: "dollarsign.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatCurrency(calculatedTotal))
                    .font(.headline)
            }
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Status", systemImage: "flag")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("Status", selection: $status) {
                    ForEach(ScopeItemStatus.allCases) { s in
                        Text(s.displayTitle).tag(s)
                    }
                }
                .pickerStyle(.segmented)
            }

            Divider()

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

    // MARK: - Section Card

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Calculated Total

    private var calculatedTotal: Decimal {
        let materialTotal = resourceEntries.reduce(Decimal.zero) { sum, entry in
            if let cost = entry.resource.unitCost {
                return sum + (entry.quantity * cost)
            }
            return sum
        }

        let laborTotal: Decimal = {
            guard let hours = Decimal(string: laborHours),
                  let rate = selectedMember?.hourlyRate else { return .zero }
            return hours * rate
        }()

        let fixed = Decimal(string: fixedCost) ?? .zero
        let subtotal = materialTotal + laborTotal + fixed
        let markup = Decimal(string: costMarkup) ?? 0
        return subtotal * (1 + (markup / 100))
    }

    // MARK: - Add Resource Entry

    private func addResourceEntry() {
        guard let resource = pendingResource,
              let qty = Decimal(string: pendingQuantity) else { return }

        resourceEntries.append(ResourceEntry(resource: resource, quantity: qty, unit: pendingUnit))
        pendingResource = nil
        pendingQuantity = ""
        pendingUnit = .each
    }

    // MARK: - Save

    private func saveScopeItem() {
        guard let businessKey = businessManager.businessKey else { return }

        let markupDecimal: Decimal? = Decimal(string: costMarkup).map { $0 / 100 }

        let scopeItem = ScopeItem(
            businessKey: businessKey,
            laborHours: Decimal(string: laborHours),
            fixedCost: Decimal(string: fixedCost),
            costMarkup: markupDecimal,
            description: itemDescription.isEmpty ? nil : itemDescription,
            status: status
        )
        scopeItem.notes = notes.isEmpty ? nil : notes
        scopeItem.project = project
        scopeItem.assignedMember = selectedMember

        modelContext.insert(scopeItem)

        for entry in resourceEntries {
            let sir = ScopeItemResource(
                businessKey: businessKey,
                quantity: entry.quantity,
                unit: entry.unit
            )
            sir.resource = entry.resource
            sir.scopeItem = scopeItem
            modelContext.insert(sir)
        }

        dismiss()
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Resource Entry

private struct ResourceEntry: Identifiable {
    let id = UUID()
    let resource: Resource
    let quantity: Decimal
    let unit: UnitOfMeasure
}
