//
//  ResourceRowView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI

struct ResourceRowView: View {
    let resource: Resource

    @Environment(DrawerRouter.self) private var drawerRouter

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: resource.category.systemImage)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(categoryColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(resource.name)
                    .font(.headline)

                categoryDetail

                if resource.allocatedQuantity > 0 {
                    Label(
                        "\(resource.allocatedQuantity as NSDecimalNumber) allocated · \(resource.availableQuantity as NSDecimalNumber) available",
                        systemImage: "chart.bar.fill"
                    )
                    .font(.caption2)
                    .foregroundStyle(resource.availableQuantity < 0 ? Color.orange : Color.secondary)
                }
            }

            Spacer()

            if resource.isMaterialType && !resource.materialVariants.isEmpty {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !resource.isAvailable {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            if resource.isMaterialType {
                drawerRouter.present(.materialVariants(resource))
            }
        }
    }

    // MARK: - Category-Specific Detail

    @ViewBuilder
    private var categoryDetail: some View {
        switch resource.category {
        case .equipment:
            equipmentDetail

        case .material:
            materialDetail

        case .vehicle:
            vehicleDetail

        case .tool:
            toolDetail
        }
    }

    private var equipmentDetail: some View {
        HStack(spacing: 8) {
            if !resource.equipmentMaterials.isEmpty {
                Label(
                    "Uses: \(resource.equipmentMaterials.map(\.name).prefix(3).joined(separator: ", "))",
                    systemImage: "shippingbox"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            if let unitCost = resource.unitCost {
                Label(formatCurrency(unitCost), systemImage: "dollarsign")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var materialDetail: some View {
        HStack(spacing: 8) {
            if resource.isMaterialType {
                let count = resource.materialVariants.count
                Label(
                    "\(count) variant\(count == 1 ? "" : "s")",
                    systemImage: "list.bullet"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            } else if resource.isMaterialVariant {
                if let variant = resource.variantLabel,
                   let parent = resource.parentMaterial?.materialTypeName {
                    Text("\(variant) · \(parent)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    Label("\(resource.quantity as NSDecimalNumber) \(resource.unit.abbreviation)", systemImage: "number")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let unitCost = resource.unitCost {
                        Label(formatCurrency(unitCost), systemImage: "dollarsign")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Label("\(resource.quantity as NSDecimalNumber) \(resource.unit.abbreviation)", systemImage: "number")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let unitCost = resource.unitCost {
                        Label(formatCurrency(unitCost), systemImage: "dollarsign")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var vehicleDetail: some View {
        HStack(spacing: 8) {
            if !resource.vehicleDisplayLabel.isEmpty {
                Text(resource.vehicleDisplayLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let km = resource.startingKilometers {
                Label(
                    "\(km.formatted()) km",
                    systemImage: "gauge.with.dots.needle.67percent"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var toolDetail: some View {
        Label(resource.toolLocationLabel, systemImage: resource.isShopTool ? "building.2" : "car")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    // MARK: - Helpers

    private var categoryColor: Color {
        switch resource.category {
        case .equipment: .blue
        case .material: .green
        case .vehicle: .purple
        case .tool: .orange
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Material Variants Sheet

struct MaterialVariantsSheet: View {
    let materialType: Resource

    @Environment(\.dismissDrawer) private var dismiss

    private var sortedVariants: [Resource] {
        materialType.materialVariants.sorted { $0.variantLabel ?? "" < $1.variantLabel ?? "" }
    }

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: materialType.materialTypeName ?? materialType.name,
                leadingText: "Back",
                leadingAction: { dismiss() },
                trailingText: "Done",
                trailingAction: { dismiss() }
            )

            ScrollView {
                VStack(spacing: 12) {
                    if sortedVariants.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "shippingbox")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)

                            Text("No variants yet")
                                .font(.headline)

                            Text("Add variants from the + menu under Material.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(sortedVariants) { variant in
                            variantRow(variant)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
    }

    private func variantRow(_ variant: Resource) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "circle.fill")
                .font(.caption2)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 4) {
                Text(variant.variantLabel ?? variant.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    Label("\(variant.quantity as NSDecimalNumber) \(variant.unit.abbreviation)", systemImage: "number")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let unitCost = variant.unitCost {
                        Label(formatCurrency(unitCost), systemImage: "dollarsign")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if variant.allocatedQuantity > 0 {
                    Label(
                        "\(variant.allocatedQuantity as NSDecimalNumber) allocated · \(variant.availableQuantity as NSDecimalNumber) available",
                        systemImage: "chart.bar.fill"
                    )
                    .font(.caption2)
                    .foregroundStyle(variant.availableQuantity < 0 ? Color.orange : Color.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}
