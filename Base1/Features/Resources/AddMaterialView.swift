//
//  AddMaterialView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct AddMaterialView: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Mode

    enum MaterialMode: String, CaseIterable, Identifiable {
        case newType = "New Type"
        case addVariant = "Add Variant"

        var id: String { rawValue }
    }

    @State private var mode: MaterialMode = .newType

    // MARK: - New Type Fields

    @State private var typeName = ""

    // MARK: - Variant Fields

    @State private var selectedParent: Resource?
    @State private var variantLabel = ""
    @State private var quantity = ""
    @State private var unit = ""
    @State private var unitCost = ""

    // MARK: - Queries

    @Query(sort: \Resource.name)
    private var allResources: [Resource]

    private var materialTypes: [Resource] {
        allResources.filter { $0.isMaterialType }
    }

    private var canSave: Bool {
        switch mode {
        case .newType: !typeName.isEmpty
        case .addVariant: selectedParent != nil && !variantLabel.isEmpty
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Mode Picker
                    sectionCard {
                        Picker("Mode", selection: $mode) {
                            ForEach(MaterialMode.allCases) { m in
                                Text(m.rawValue).tag(m)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    switch mode {
                    case .newType:
                        newTypeSection
                    case .addVariant:
                        variantSection
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Add Material")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    // MARK: - New Type Section

    private var newTypeSection: some View {
        sectionCard {
            LabeledTextField("Type Name", text: $typeName, icon: "tag")

            Text("e.g., Orbital Sand Paper, Deck Stain")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Variant Section

    private var variantSection: some View {
        Group {
            sectionCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Material Type", systemImage: "shippingbox")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if materialTypes.isEmpty {
                        Text("No material types yet — create one first")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Material Type", selection: $selectedParent) {
                            Text("Select a type…").tag(Resource?.none)
                            ForEach(materialTypes) { mt in
                                Text(mt.materialTypeName ?? mt.name).tag(Resource?.some(mt))
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                Divider()

                LabeledTextField("Variant Label", text: $variantLabel, icon: "tag")

                Text("e.g., 40 grit, Chocolate Brown")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            sectionCard {
                LabeledTextField("Quantity", text: $quantity, icon: "number", keyboardType: .numberPad)

                Divider()

                LabeledTextField("Unit (e.g. sqft, pcs)", text: $unit, icon: "ruler")

                Divider()

                LabeledTextField("Unit Cost", text: $unitCost, icon: "dollarsign", keyboardType: .decimalPad)
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

    private func save() {
        guard let businessKey = businessManager.businessKey else { return }

        switch mode {
        case .newType:
            let resource = Resource(
                businessKey: businessKey,
                name: typeName,
                category: .material,
                materialTypeName: typeName
            )
            resource.business = businessManager.currentBusiness
            modelContext.insert(resource)

        case .addVariant:
            guard let parent = selectedParent else { return }
            let resource = Resource(
                businessKey: businessKey,
                name: "\(parent.materialTypeName ?? parent.name) — \(variantLabel)",
                category: .material,
                unitCost: Decimal(string: unitCost),
                quantity: Int(quantity) ?? 1,
                unit: unit.isEmpty ? nil : unit,
                variantLabel: variantLabel
            )
            resource.parentMaterial = parent
            resource.business = businessManager.currentBusiness
            modelContext.insert(resource)
        }

        dismiss()
    }
}
