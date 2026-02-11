//
//  Tab4View.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

struct Tab4View: View {

    @State private var showingAddEquipment = false
    @State private var showingAddMaterial = false
    @State private var showingAddVehicle = false
    @State private var showingAddTool = false

    @State private var showingEquipmentList = false
    @State private var showingMaterialList = false
    @State private var showingVehicleList = false
    @State private var showingToolList = false

    @Environment(BusinessManager.self) private var businessManager

    @Query(sort: \Resource.name)
    private var allResources: [Resource]

    // MARK: - Counts

    private var businessResources: [Resource] {
        guard let key = businessManager.businessKey else { return [] }
        return allResources.filter { $0.businessKey == key && $0.parentMaterial == nil }
    }

    private func count(for category: ResourceCategory) -> Int {
        businessResources.filter { $0.category == category }.count
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {

            Text("Resources")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                categoryCard(
                    title: "Equipment",
                    icon: "gearshape.2",
                    color: .blue,
                    count: count(for: .equipment),
                    onAdd: { showingAddEquipment = true },
                    onOpen: { showingEquipmentList = true }
                )

                categoryCard(
                    title: "Materials",
                    icon: "shippingbox",
                    color: .green,
                    count: count(for: .material),
                    onAdd: { showingAddMaterial = true },
                    onOpen: { showingMaterialList = true }
                )

                categoryCard(
                    title: "Vehicles",
                    icon: "car",
                    color: .purple,
                    count: count(for: .vehicle),
                    onAdd: { showingAddVehicle = true },
                    onOpen: { showingVehicleList = true }
                )

                categoryCard(
                    title: "Tools",
                    icon: "wrench.and.screwdriver",
                    color: .orange,
                    count: count(for: .tool),
                    onAdd: { showingAddTool = true },
                    onOpen: { showingToolList = true }
                )
            }
            .padding(.horizontal)

            Spacer()
        }
        .sheet(isPresented: $showingAddEquipment) { AddEquipmentView() }
        .sheet(isPresented: $showingAddMaterial) { AddMaterialView() }
        .sheet(isPresented: $showingAddVehicle) { AddVehicleView() }
        .sheet(isPresented: $showingAddTool) { AddToolView() }
        .sheet(isPresented: $showingEquipmentList) { ResourceListSheet(category: .equipment) }
        .sheet(isPresented: $showingMaterialList) { ResourceListSheet(category: .material) }
        .sheet(isPresented: $showingVehicleList) { ResourceListSheet(category: .vehicle) }
        .sheet(isPresented: $showingToolList) { ResourceListSheet(category: .tool) }
    }

    // MARK: - Category Card

    private func categoryCard(
        title: String,
        icon: String,
        color: Color,
        count: Int,
        onAdd: @escaping () -> Void,
        onOpen: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(color)

            Text(title)
                .font(.headline)

            Text("\(count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Button(action: onAdd) {
                    Label("Add", systemImage: "plus")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .tint(color)

                Button(action: onOpen) {
                    Label("Open", systemImage: "list.bullet")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Resource List Sheet

struct ResourceListSheet: View {
    let category: ResourceCategory

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Resource.name)
    private var allResources: [Resource]

    private var resources: [Resource] {
        guard let key = businessManager.businessKey else { return [] }
        return allResources.filter { $0.businessKey == key && $0.category == category && $0.parentMaterial == nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if resources.isEmpty {
                    EmptyResourcesView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(resources) { resource in
                                ResourceRowView(resource: resource)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(category.displayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
