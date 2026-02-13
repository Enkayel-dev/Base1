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
    @State private var selectedParentResource: Resource?
    @State private var selectedVariantResource: Resource?
    @State private var pendingQuantity = ""
    @State private var pendingUnit: UnitOfMeasure = .each
    @State private var pendingMeasurements: Set<ProjectMeasurement> = []
    @State private var pendingWasteFactor = ""
    @State private var pendingCoats = ""

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
                            HStack(spacing: 8) {
                                Text("\(entry.quantity as NSDecimalNumber) \(entry.unit.abbreviation)")
                                if !entry.measurements.isEmpty {
                                    Text("•")
                                    Text(entry.measurements.map { $0.name }.joined(separator: ", "))
                                }
                            }
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
                    Picker("Material Type", selection: $selectedParentResource) {
                        Text("Select Material Type").tag(Resource?.none)
                        ForEach(businessResources.filter { $0.category == .material && $0.parentMaterial == nil }) { resource in
                            Text(resource.name).tag(Resource?.some(resource))
                        }
                    }
                    .pickerStyle(.menu)

                    if let parent = selectedParentResource {
                        Picker("Variant", selection: $selectedVariantResource) {
                            Text("Select Variant").tag(Resource?.none)
                            ForEach(parent.materialVariants) { variant in
                                Text(variant.variantLabel ?? variant.name).tag(Resource?.some(variant))
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedVariantResource) { _, newValue in
                            if let variant = newValue {
                                pendingUnit = variant.unit
                                // Auto-fill defaults from the resource
                                if let waste = variant.defaultWasteFactor {
                                    pendingWasteFactor = "\(waste * 100 as NSDecimalNumber)"
                                } else {
                                    pendingWasteFactor = ""
                                }
                                
                                if let coats = variant.defaultCoats {
                                    pendingCoats = "\(coats)"
                                } else {
                                    pendingCoats = ""
                                }
                            }
                        }
                    }

                    if let res = selectedVariantResource {
                        if let rate = res.coverageRate, let cUnit = res.coverageUnit {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Coverage: 1 \(res.unit.displayTitle) covers \(rate as NSDecimalNumber) \(cUnit.abbreviation)")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Select Measurements")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(project.measurements) { m in
                                                Button {
                                                    if pendingMeasurements.contains(m) {
                                                        pendingMeasurements.remove(m)
                                                    } else {
                                                        pendingMeasurements.insert(m)
                                                    }
                                                } label: {
                                                    HStack(spacing: 4) {
                                                        Text(m.name)
                                                        Text("(\(m.value as NSDecimalNumber) \(m.unit.abbreviation))")
                                                            .font(.caption2)
                                                            .opacity(0.8)
                                                        
                                                        if pendingMeasurements.contains(m) {
                                                            Image(systemName: "checkmark.circle.fill")
                                                        }
                                                    }
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 6)
                                                    .background(pendingMeasurements.contains(m) ? Color.blue : Color.secondary.opacity(0.1))
                                                    .foregroundStyle(pendingMeasurements.contains(m) ? .white : .primary)
                                                    .clipShape(Capsule())
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)

                                if !pendingMeasurements.isEmpty {
                                    HStack(spacing: 12) {
                                        LabeledTextField("Waste %", text: $pendingWasteFactor, icon: "percent", keyboardType: .decimalPad)
                                        LabeledTextField("Coats", text: $pendingCoats, icon: "paintpalette", keyboardType: .numberPad)
                                    }

                                    if let calc = temporaryCalculatedQuantity {
                                        let wasteStr = pendingWasteFactor.isEmpty ? "0" : pendingWasteFactor
                                        let coatsStr = pendingCoats.isEmpty ? "1" : pendingCoats
                                        
                                        // Calculate total area for display
                                        let totalArea: Decimal = pendingMeasurements.reduce(0) { sum, m in
                                            let converted = m.unit.convert(m.value, to: cUnit) ?? 0
                                            return sum + converted
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Usage: \(calc as NSDecimalNumber) \(res.unit.abbreviation)")
                                                .font(.headline)
                                                .foregroundStyle(.blue)
                                            
                                            Text("(at \(totalArea as NSDecimalNumber) \(cUnit.abbreviation) total, \(coatsStr) coat\(coatsStr == "1" ? "" : "s"), \(wasteStr)% waste)")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }

                        if pendingMeasurements.isEmpty {
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
                        }

                        Button {
                            addResourceEntry()
                        } label: {
                            Label("Add Resource", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                        }
                        .disabled(pendingQuantity.isEmpty && temporaryCalculatedQuantity == nil)
                    }
                }

                if let res = selectedVariantResource {
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

    // MARK: - Temporary Calculation

    private var temporaryCalculatedQuantity: Decimal? {
        guard let res = selectedVariantResource,
              !pendingMeasurements.isEmpty,
              let rate = res.coverageRate,
              rate > 0 else { return nil }

        let cUnit = res.coverageUnit ?? .sqft
        var totalConvertedValue: Decimal = 0
        
        for m in pendingMeasurements {
            if let converted = m.unit.convert(m.value, to: cUnit) {
                totalConvertedValue += converted
            }
        }
        
        if totalConvertedValue == 0 { return nil }

        let usageUnits = (totalConvertedValue / rate)
        let waste = 1 + ((Decimal(string: pendingWasteFactor) ?? (res.defaultWasteFactor ?? 0) * 100) / 100)
        let coats = Decimal(integerLiteral: Int(pendingCoats) ?? (res.defaultCoats ?? 1))
        
        let inventoryQty = usageUnits * coats * waste
        
        return inventoryQty
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
        guard let resource = selectedVariantResource else { return }
        
        let qty: Decimal
        let isOverridden: Bool
        
        if let calc = temporaryCalculatedQuantity, pendingQuantity.isEmpty {
            qty = calc
            isOverridden = false
        } else {
            qty = Decimal(string: pendingQuantity) ?? 0
            isOverridden = true
        }

        resourceEntries.append(ResourceEntry(
            resource: resource,
            quantity: qty,
            unit: pendingUnit,
            measurements: Array(pendingMeasurements),
            wasteFactor: Decimal(string: pendingWasteFactor),
            coats: Int(pendingCoats),
            isQuantityOverridden: isOverridden
        ))
        
        selectedVARIANT_RESET()
    }

    private func selectedVARIANT_RESET() {
        selectedParentResource = nil
        selectedVariantResource = nil
        pendingQuantity = ""
        pendingUnit = .each
        pendingMeasurements = []
        pendingWasteFactor = ""
        pendingCoats = ""
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
                unit: entry.unit,
                wasteFactor: entry.wasteFactor,
                coats: entry.coats,
                isQuantityOverridden: entry.isQuantityOverridden
            )
            sir.resource = entry.resource
            sir.measurements = entry.measurements
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
    let measurements: [ProjectMeasurement]
    let wasteFactor: Decimal?
    let coats: Int?
    let isQuantityOverridden: Bool
}
