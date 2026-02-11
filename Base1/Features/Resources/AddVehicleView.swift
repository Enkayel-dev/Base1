//
//  AddVehicleView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct AddVehicleView: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form Fields

    @State private var name = ""
    @State private var make = ""
    @State private var model = ""
    @State private var startingKm = ""
    @State private var serviceNotes = ""
    @State private var isAvailable = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    detailsSection
                    serviceSection
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Add Vehicle")
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
            LabeledTextField("Name", text: $name, icon: "car")

            Divider()

            LabeledTextField("Make", text: $make, icon: "building.2")

            Divider()

            LabeledTextField("Model", text: $model, icon: "tag")

            Divider()

            LabeledTextField("Starting Kilometers", text: $startingKm, icon: "gauge.with.dots.needle.67percent", keyboardType: .numberPad)

            Divider()

            Toggle(isOn: $isAvailable) {
                Label("Available", systemImage: "checkmark.circle")
            }
        }
    }

    // MARK: - Service Section

    private var serviceSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Service Notes", systemImage: "wrench.and.screwdriver")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $serviceNotes)
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
            category: .vehicle,
            quantity: 1,
            isAvailable: isAvailable,
            vehicleMake: make.isEmpty ? nil : make,
            vehicleModel: model.isEmpty ? nil : model,
            startingKilometers: Int(startingKm),
            serviceNotes: serviceNotes.isEmpty ? nil : serviceNotes
        )
        resource.business = businessManager.currentBusiness

        modelContext.insert(resource)
        dismiss()
    }
}
