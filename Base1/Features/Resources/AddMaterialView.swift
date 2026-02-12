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
    @Environment(\.dismissDrawer) private var dismiss

    // MARK: - Material Info

    @State private var typeName = ""

    // MARK: - Variant Fields

    struct MaterialVariantDraft: Identifiable {
        let id = UUID()
        var variantLabel: String
        var quantity: String
        var unit: UnitOfMeasure
        var unitCost: String
        var coverageRate: String
        var coverageUnit: UnitOfMeasure
        var defaultWasteFactor: String
        var defaultCoats: String
    }

    @State private var variants: [MaterialVariantDraft] = []
    // Fields for current entry
    @State private var variantLabel = ""
    @State private var quantity = ""
    @State private var selectedUnit: UnitOfMeasure = .each
    @State private var unitCost = ""

    // MARK: - Coverage Fields

    @State private var coverageRate = ""
    @State private var coverageUnit: UnitOfMeasure = .sqft
    @State private var defaultWasteFactor = ""
    @State private var defaultCoats = ""

    // MARK: - Queries

    @Query(sort: \Resource.name)
    private var allResources: [Resource]

    private var canSave: Bool {
        !typeName.isEmpty && (!variants.isEmpty || canAddVariant)
    }

    private var canAddVariant: Bool {
        !variantLabel.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Add Material",
                leadingAction: { dismiss() },
                trailingAction: { save() },
                isTrailingDisabled: !canSave
            )

            ScrollView {
                VStack(spacing: 24) {
                    if !variants.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Added Variants", systemImage: "square.stack.3d.down.right")
                                .font(.headline)

                            VStack(spacing: 8) {
                                ForEach(variants) { variant in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(variant.variantLabel)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
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
                    }

                    sectionCard {
                        LabeledTextField("Material Type", text: $typeName, icon: "shippingbox")
                        Text("e.g., Orbital Sand Paper")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    sectionCard {
                        Text("Inventory Details")
                            .font(.headline)
                        
                        LabeledTextField("Variant Name", text: $variantLabel, icon: "tag")
                        
                        Divider()
                        
                        HStack(spacing: 12) {
                            LabeledTextField("Stock Qty", text: $quantity, icon: "number", keyboardType: .decimalPad)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Unit")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Picker("Unit", selection: $selectedUnit) {
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

                        LabeledTextField("Unit Cost", text: $unitCost, icon: "dollarsign", keyboardType: .decimalPad)
                    }

                    sectionCard {
                        Text("Usage Conversion")
                            .font(.headline)
                        
                        Label("1 \(selectedUnit.displayTitle) covers:", systemImage: "paintpalette")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            LabeledTextField("Rate", text: $coverageRate, icon: "ruler", keyboardType: .decimalPad)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("In")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Picker("Coverage Unit", selection: $coverageUnit) {
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

                        HStack(spacing: 12) {
                            LabeledTextField("Default Waste %", text: $defaultWasteFactor, icon: "percent", keyboardType: .decimalPad)
                            LabeledTextField("Default Coats", text: $defaultCoats, icon: "number", keyboardType: .numberPad)
                        }

                        Divider()

                        Button {
                            addVariantDraft()
                        } label: {
                            Label("Add Variant", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canAddVariant)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
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

        // 1. Add current form as a draft if valid
        if canAddVariant {
            addVariantDraft()
        }

        // 2. Resolve or Create Parent Resource
        let parent: Resource
        if let existing = allResources.first(where: { $0.isMaterialType && ($0.materialTypeName == typeName || $0.name == typeName) }) {
            parent = existing
        } else {
            parent = Resource(
                businessKey: businessKey,
                name: typeName,
                category: .material,
                materialTypeName: typeName
            )
            parent.business = businessManager.currentBusiness
            modelContext.insert(parent)
        }

        // 3. Persist all drafts
        for draft in variants {
            let resource = Resource(
                businessKey: businessKey,
                name: "\(typeName) — \(draft.variantLabel)",
                category: .material,
                unitCost: Decimal(string: draft.unitCost),
                quantity: Decimal(string: draft.quantity) ?? 1,
                unit: draft.unit,
                variantLabel: draft.variantLabel,
                coverageRate: Decimal(string: draft.coverageRate),
                coverageUnit: draft.coverageUnit,
                defaultWasteFactor: Decimal(string: draft.defaultWasteFactor).map { $0 / 100 },
                defaultCoats: Int(draft.defaultCoats)
            )
            resource.parentMaterial = parent
            resource.business = businessManager.currentBusiness
            modelContext.insert(resource)
        }

        dismiss()
    }

    private func addVariantDraft() {
        let draft = MaterialVariantDraft(
            variantLabel: variantLabel,
            quantity: quantity,
            unit: selectedUnit,
            unitCost: unitCost,
            coverageRate: coverageRate,
            coverageUnit: coverageUnit,
            defaultWasteFactor: defaultWasteFactor,
            defaultCoats: defaultCoats
        )
        variants.append(draft)
        
        // Reset fields
        variantLabel = ""
        quantity = ""
        unitCost = ""
        coverageRate = ""
        defaultWasteFactor = ""
        defaultCoats = ""
    }
}
