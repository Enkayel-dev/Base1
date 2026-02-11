//
//  ProjectDetailView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    let project: Project

    @Environment(DrawerRouter.self) private var drawerRouter

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    projectHeader
                    assignedTeamSection
                    scopeItemsSection
                    summarySection
                }
                .padding()
                .padding(.bottom, 40)
            }
            .navigationTitle(project.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Project Header

    private var projectHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(project.status.displayTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(statusColor.gradient)
                    .clipShape(Capsule())

                Spacer()

                if let jobType = project.projectTypeRaw {
                    Text(jobType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let client = project.client {
                Label(client.displayName, systemImage: "person")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let description = project.projectDescription {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Assigned Team Section

    @ViewBuilder
    private var assignedTeamSection: some View {
        if !project.assignedMembers.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Assigned Team")
                    .font(.headline)

                VStack(spacing: 0) {
                    ForEach(project.assignedMembers) { member in
                        MemberRowView(member: member)
                        if member.id != project.assignedMembers.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Scope Items Section

    private var scopeItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scope Items")
                    .font(.headline)

                Spacer()

                Button {
                    drawerRouter.present(.addScopeItem(project))
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
            }

            if project.scopeItems.isEmpty {
                Text("No scope items yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(project.scopeItems.sorted(by: { $0.createdAt > $1.createdAt })) { item in
                    ScopeItemRowView(scopeItem: item)
                }
            }
        }
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                summaryCard(
                    title: "Scope Cost",
                    value: formatCurrency(project.totalScopeCost),
                    icon: "dollarsign.circle"
                )

                summaryCard(
                    title: "Labor Hours",
                    value: "\(project.totalLaborHours as NSDecimalNumber)h",
                    icon: "clock"
                )
            }

            if project.hasInventoryIssues {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Some scope items need additional inventory")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func summaryCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private var statusColor: Color {
        switch project.status {
        case .planning: .blue
        case .inProgress: .green
        case .onHold: .orange
        case .completed: .purple
        case .cancelled: .red
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}
