//
//  ScopeItemRowView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI

struct ScopeItemRowView: View {
    let scopeItem: ScopeItem

    var body: some View {
        HStack(spacing: 12) {
            // Icon based on item type
            Image(systemName: itemIcon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(statusColor.gradient)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(scopeItem.displayName)
                    .font(.headline)

                // Cost breakdown
                HStack(spacing: 8) {
                    if scopeItem.materialCost > 0 {
                        Label(formatCurrency(scopeItem.materialCost), systemImage: "shippingbox")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let laborCost = scopeItem.laborCost, laborCost > 0 {
                        Label(formatCurrency(laborCost), systemImage: "person")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let fixedCost = scopeItem.fixedCost, fixedCost > 0 {
                        Label(formatCurrency(fixedCost), systemImage: "dollarsign")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Resource count
                if !scopeItem.scopeItemResources.isEmpty {
                    let count = scopeItem.scopeItemResources.count
                    Label(
                        "\(count) resource\(count == 1 ? "" : "s")",
                        systemImage: "cube.box"
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }

                // Inventory warnings
                if scopeItem.hasInventoryIssues {
                    Label(
                        "Inventory shortfall",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(.caption2)
                    .foregroundStyle(.orange)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(scopeItem.status.displayTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.gradient)
                    .clipShape(Capsule())

                Text(formatCurrency(scopeItem.estimatedCost))
                    .font(.caption)
                    .fontWeight(.semibold)

                if let hours = scopeItem.laborHours {
                    Label("\(hours as NSDecimalNumber)h", systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if let member = scopeItem.assignedMember {
                    Text(member.initials)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private var itemIcon: String {
        if let first = scopeItem.scopeItemResources.first?.resource?.category {
            return first.systemImage
        }
        if scopeItem.laborHours != nil { return "person.fill" }
        if scopeItem.fixedCost != nil { return "dollarsign.circle" }
        return "doc.text"
    }

    private var statusColor: Color {
        switch scopeItem.status {
        case .pending: .orange
        case .ordered: .blue
        case .fulfilled: .green
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}
