//
//  AddMeasurementView.swift
//  Base1
//
//  Created by Antigravity on 2026-02-12.
//

import SwiftUI
import SwiftData

struct AddMeasurementView: View {
    let project: Project

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss

    @State private var name = ""
    @State private var value = ""
    @State private var unit: UnitOfMeasure = .sqft
    @State private var notes = ""

    private var canSave: Bool {
        !name.isEmpty && !value.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Add Measurement",
                leadingAction: { dismiss() },
                trailingAction: { save() },
                isTrailingDisabled: !canSave
            )

            ScrollView {
                VStack(spacing: 24) {
                    sectionCard {
                        LabeledTextField("Name", text: $name, icon: "tag")
                        Text("e.g., Front Deck, Kitchen Floor")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    sectionCard {
                        HStack(spacing: 12) {
                            LabeledTextField("Value", text: $value, icon: "number", keyboardType: .decimalPad)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Unit")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Picker("Unit", selection: $unit) {
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
                    }

                    sectionCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Notes", systemImage: "note.text")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextEditor(text: $notes)
                                .frame(minHeight: 100)
                                .scrollContentBackground(.hidden)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func save() {
        guard let businessKey = businessManager.businessKey,
              let val = Decimal(string: value) else { return }

        let measurement = ProjectMeasurement(
            businessKey: businessKey,
            name: name,
            value: val,
            unit: unit,
            notes: notes.isEmpty ? nil : notes
        )
        measurement.project = project
        modelContext.insert(measurement)

        dismiss()
    }
}
