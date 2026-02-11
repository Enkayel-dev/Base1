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
            // Resource category icon
            if let category = scopeItem.resource?.category {
                Image(systemName: category.systemImage)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(statusColor.gradient)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(scopeItem.displayName)
                    .font(.headline)

                HStack(spacing: 8) {
                    Label(
                        "\(scopeItem.quantityNeeded) \(scopeItem.resource?.unit ?? "units")",
                        systemImage: "number"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if let cost = scopeItem.estimatedCost {
                        Label(formatCurrency(cost), systemImage: "dollarsign")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if scopeItem.inventoryShortfall > 0 {
                    Label(
                        "Need to order: \(scopeItem.inventoryShortfall) more",
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

                if let hours = scopeItem.laborHours {
                    Label("\(hours as NSDecimalNumber)h", systemImage: "clock")
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
