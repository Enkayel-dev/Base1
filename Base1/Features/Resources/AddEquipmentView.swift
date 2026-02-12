//
//  AddEquipmentView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct AddEquipmentView: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss

    // MARK: - Form Fields

    @State private var name = ""
    @State private var resourceDescription = ""
    @State private var quantity = ""
    @State private var selectedUnit: UnitOfMeasure = .each
    @State private var unitCost = ""
    @State private var isAvailable = true
    @State private var notes = ""
    @State private var selectedMaterials: Set<PersistentIdentifier> = []

    @Query(sort: \Resource.name)
    private var allResources: [Resource]

    private var materialResources: [Resource] {
        allResources.filter { $0.category == .material }
    }

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Add Equipment",
                leadingAction: { dismiss() },
                trailingAction: { save() },
                isTrailingDisabled: name.isEmpty
            )

            ScrollView {
                VStack(spacing: 24) {
                    detailsSection
                    materialsSection
                    inventorySection
                    notesSection
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        sectionCard {
            LabeledTextField("Name", text: $name, icon: "tag")

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Label("Description", systemImage: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $resourceDescription)
                    .frame(minHeight: 60)
                    .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Materials Used Section

    private var materialsSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Materials Used", systemImage: "shippingbox")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if materialResources.isEmpty {
                    Text("No materials yet — add materials first")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(materialResources) { material in
                        Button {
                            if selectedMaterials.contains(material.persistentModelID) {
                                selectedMaterials.remove(material.persistentModelID)
                            } else {
                                selectedMaterials.insert(material.persistentModelID)
                            }
                        } label: {
                            HStack {
                                Image(systemName: selectedMaterials.contains(material.persistentModelID) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedMaterials.contains(material.persistentModelID) ? .blue : .secondary)

                                Text(material.name)
                                    .foregroundStyle(.primary)

                                if let variant = material.variantLabel {
                                    Text("· \(variant)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Inventory Section

    private var inventorySection: some View {
        sectionCard {
            LabeledTextField("Quantity", text: $quantity, icon: "number", keyboardType: .decimalPad)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Label("Unit", systemImage: "ruler")
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

            Divider()

            LabeledTextField("Unit Cost", text: $unitCost, icon: "dollarsign", keyboardType: .decimalPad)

            Divider()

            Toggle(isOn: $isAvailable) {
                Label("Available", systemImage: "checkmark.circle")
            }
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
                    .frame(minHeight: 80)
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

    private func save() {
        guard let businessKey = businessManager.businessKey else { return }

        let resource = Resource(
            businessKey: businessKey,
            name: name,
            description: resourceDescription.isEmpty ? nil : resourceDescription,
            category: .equipment,
            unitCost: Decimal(string: unitCost),
            quantity: Decimal(string: quantity) ?? 1,
            unit: selectedUnit,
            isAvailable: isAvailable
        )
        resource.notes = notes.isEmpty ? nil : notes
        resource.business = businessManager.currentBusiness

        let linked = allResources.filter { selectedMaterials.contains($0.persistentModelID) }
        resource.equipmentMaterials = linked

        modelContext.insert(resource)
        dismiss()
    }
}
