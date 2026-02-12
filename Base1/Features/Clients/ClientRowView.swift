//
//  ClientRowView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

struct ClientRowView: View {
    let client: Client

    @Environment(DrawerRouter.self) private var drawerRouter

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

            // Data completeness icons — always visible
            HStack(spacing: 12) {
                fieldIcon("envelope", filled: client.email != nil && !client.email!.isEmpty)
                fieldIcon("phone", filled: client.phone != nil && !client.phone!.isEmpty)
                fieldIcon("mappin.and.ellipse", filled: client.address != nil && !client.address!.isEmpty)
                fieldIcon("folder", filled: hasOpenProject)
                fieldIcon("calendar", filled: !client.appointments.isEmpty)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture { drawerRouter.present(.clientDetail(client)) }
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
