//
//  AddToolView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct AddToolView: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form Fields

    @State private var name = ""
    @State private var quantity = ""
    @State private var notes = ""

    // MARK: - Location

    enum ToolLocation: String, CaseIterable, Identifiable {
        case shop = "Shop"
        case vehicle = "Vehicle"

        var id: String { rawValue }
    }

    @State private var locationChoice: ToolLocation = .shop
    @State private var selectedVehicle: Resource?

    @Query(sort: \Resource.name)
    private var allResources: [Resource]

    private var vehicleResources: [Resource] {
        allResources.filter { $0.category == .vehicle }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    detailsSection
                    locationSection
                    notesSection
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Add Tool")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty)
                }
            }
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        sectionCard {
            LabeledTextField("Name", text: $name, icon: "wrench.and.screwdriver")

            Divider()

            LabeledTextField("Quantity", text: $quantity, icon: "number", keyboardType: .numberPad)
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Location", systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Location", selection: $locationChoice) {
                    ForEach(ToolLocation.allCases) { loc in
                        Text(loc.rawValue).tag(loc)
                    }
                }
                .pickerStyle(.segmented)
            }

            switch locationChoice {
            case .shop:
                HStack {
                    Image(systemName: "building.2")
                        .foregroundStyle(.secondary)
                    Text(businessManager.currentBusiness?.address ?? "No address set")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

            case .vehicle:
                if vehicleResources.isEmpty {
                    Text("No vehicles yet — add a vehicle first")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Vehicle", selection: $selectedVehicle) {
                        Text("Select a vehicle…").tag(Resource?.none)
                        ForEach(vehicleResources) { vehicle in
                            Text(vehicle.name).tag(Resource?.some(vehicle))
                        }
                    }
                    .pickerStyle(.menu)
                }
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
            category: .tool,
            quantity: Int(quantity) ?? 1,
            isShopTool: locationChoice == .shop
        )
        resource.notes = notes.isEmpty ? nil : notes
        resource.business = businessManager.currentBusiness

        if locationChoice == .vehicle {
            resource.assignedVehicle = selectedVehicle
        }

        modelContext.insert(resource)
        dismiss()
    }
}
