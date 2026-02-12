//
//  AddJobTypeView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct AddJobTypeView: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "hammer"

    private let iconOptions = [
        "hammer", "wrench.and.screwdriver", "house", "building.2",
        "paintbrush", "bolt", "drop", "leaf",
        "car", "truck.box", "shippingbox", "cube",
        "lightbulb", "fan", "thermometer", "pipe.and.drop"
    ]

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Add Job Type",
                leadingAction: { dismiss() },
                trailingAction: { save() },
                isTrailingDisabled: name.isEmpty
            )

            ScrollView {
                VStack(spacing: 24) {
                    sectionCard {
                        LabeledTextField("Name", text: $name, icon: "tag")
                    }

                    sectionCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Icon", systemImage: "square.grid.2x2")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                ForEach(iconOptions, id: \.self) { icon in
                                    Button {
                                        selectedIcon = icon
                                    } label: {
                                        Image(systemName: icon)
                                            .font(.title3)
                                            .frame(width: 44, height: 44)
                                            .background(selectedIcon == icon ? .blue.opacity(0.2) : .clear)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .foregroundStyle(selectedIcon == icon ? .blue : .secondary)
                                    }
                                }
                            }
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
        guard let businessKey = businessManager.businessKey else { return }

        let jobType = JobType(
            businessKey: businessKey,
            name: name,
            icon: selectedIcon
        )
        jobType.business = businessManager.currentBusiness

        modelContext.insert(jobType)
        dismiss()
    }
}
