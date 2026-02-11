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
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form Fields

    @State private var selectedResource: Resource?
    @State private var quantityNeeded = ""
    @State private var laborHours = ""
    @State private var costMarkup = ""
    @State private var itemDescription = ""
    @State private var status: ScopeItemStatus = .pending
    @State private var notes = ""

    // MARK: - Queries

    @Query(sort: \Resource.name)
    private var allResources: [Resource]

    private var businessResources: [Resource] {
        guard let key = businessManager.businessKey else { return [] }
        return allResources.filter { $0.businessKey == key }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 24) {
                        resourceSection
                        quantitySection
                        costSection
                        detailsSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Add Scope Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveScopeItem() }
                        .disabled(selectedResource == nil || quantityNeeded.isEmpty)
                }
            }
        }
    }

    // MARK: - Resource Section

    private var resourceSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Resource", systemImage: "shippingbox")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("Resource", selection: $selectedResource) {
                    Text("Select Resource").tag(Resource?.none)
                    ForEach(businessResources) { resource in
                        Label(resource.name, systemImage: resource.category.systemImage)
                            .tag(Resource?.some(resource))
                    }
                }
                .pickerStyle(.menu)

                if let res = selectedResource {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Available: \(res.availableQuantity) \(res.unit ?? "units")")
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

    // MARK: - Quantity Section

    private var quantitySection: some View {
        sectionCard {
            LabeledTextField("Quantity Needed", text: $quantityNeeded, icon: "number", keyboardType: .numberPad)

            Divider()

            LabeledTextField("Labor Hours", text: $laborHours, icon: "clock", keyboardType: .decimalPad)
        }
    }

    // MARK: - Cost Section

    private var costSection: some View {
        sectionCard {
            LabeledTextField("Cost Markup (%)", text: $costMarkup, icon: "percent", keyboardType: .decimalPad)

            if let qty = Int(quantityNeeded),
               let res = selectedResource,
               let unitCost = res.unitCost {
                let baseCost = unitCost * Decimal(qty)
                let markup = Decimal(string: costMarkup) ?? 0
                let total = baseCost * (1 + (markup / 100))

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Label("Estimated Cost", systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatCurrency(total))
                        .font(.headline)
                }
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
                Label("Description (Optional)", systemImage: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $itemDescription)
                    .frame(minHeight: 60)
                    .scrollContentBackground(.hidden)
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

    // MARK: - Save

    private func saveScopeItem() {
        guard let businessKey = businessManager.businessKey,
              let resource = selectedResource,
              let qty = Int(quantityNeeded) else { return }

        let markupDecimal: Decimal? = Decimal(string: costMarkup).map { $0 / 100 }

        let scopeItem = ScopeItem(
            businessKey: businessKey,
            quantityNeeded: qty,
            laborHours: Decimal(string: laborHours),
            costMarkup: markupDecimal,
            description: itemDescription.isEmpty ? nil : itemDescription,
            status: status
        )
        scopeItem.notes = notes.isEmpty ? nil : notes
        scopeItem.project = project
        scopeItem.resource = resource

        modelContext.insert(scopeItem)
        dismiss()
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}
