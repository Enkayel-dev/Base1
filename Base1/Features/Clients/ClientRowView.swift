//
//  ClientRowView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

struct ClientRowView: View {
    let client: Client

    private var hasOpenProject: Bool {
        client.projects.contains { $0.status == .inProgress || $0.status == .planning }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: name + status pill
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(client.firstName) \(client.lastName)")
                        .font(.headline)

                    if let company = client.companyName, !company.isEmpty {
                        Text(company)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(client.status.displayTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.gradient)
                    .clipShape(Capsule())
            }

            // Data completeness icons — only for leads
            if client.status == .lead {
                HStack(spacing: 12) {
                    fieldIcon("envelope", filled: client.email != nil && !client.email!.isEmpty)
                    fieldIcon("phone", filled: client.phone != nil && !client.phone!.isEmpty)
                    fieldIcon("mappin.and.ellipse", filled: client.address != nil && !client.address!.isEmpty)
                }
            }

            // Project icon — only for active clients
            if client.status == .active {
                fieldIcon("folder", filled: hasOpenProject)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private func fieldIcon(_ systemName: String, filled: Bool) -> some View {
        Image(systemName: systemName)
            .font(.caption)
            .foregroundStyle(filled ? .green : .gray)
    }

    private var statusColor: Color {
        switch client.status {
        case .lead: .blue
        case .active: .green
        case .closed: .gray
        }
    }
}
