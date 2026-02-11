//
//  AddScopeItemTemplateView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct AddScopeItemTemplateView: View {

    let jobType: JobType

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss

    @State private var name = ""
    @State private var quantity = "1"
    @State private var laborHours = ""
    @State private var costMarkup = ""
    @State private var selectedResource: Resource?

    @Query(sort: \Resource.name)
    private var allResources: [Resource]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    sectionCard {
                        LabeledTextField("Name", text: $name, icon: "tag")

                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Resource", systemImage: "cube.box")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Picker("Resource", selection: $selectedResource) {
                                Text("None").tag(Resource?.none)
                                ForEach(allResources) { resource in
                                    Text(resource.name).tag(Resource?.some(resource))
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        Divider()

                        LabeledTextField("Default Quantity", text: $quantity, icon: "number", keyboardType: .numberPad)

                        Divider()

                        LabeledTextField("Labor Hours", text: $laborHours, icon: "clock", keyboardType: .decimalPad)

                        Divider()

                        LabeledTextField("Cost Markup %", text: $costMarkup, icon: "percent", keyboardType: .decimalPad)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Add Scope Item")
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

        let template = ScopeItemTemplate(
            businessKey: businessKey,
            name: name,
            defaultQuantity: Int(quantity) ?? 1,
            defaultLaborHours: Decimal(string: laborHours),
            defaultCostMarkup: Decimal(string: costMarkup).map { $0 / 100 }
        )
        template.resource = selectedResource
        template.jobType = jobType
        template.business = businessManager.currentBusiness

        modelContext.insert(template)
        dismiss()
    }
}
