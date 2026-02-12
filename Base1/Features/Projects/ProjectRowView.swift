//
//  ProjectRowView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI

struct ProjectRowView: View {
    let project: Project

    @Environment(DrawerRouter.self) private var drawerRouter

    private var dateRangeText: String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        if let start = project.startDate, let due = project.dueDate {
            return "\(formatter.string(from: start)) – \(formatter.string(from: due))"
        } else if let start = project.startDate {
            return "Started \(formatter.string(from: start))"
        } else if let due = project.dueDate {
            return "Due \(formatter.string(from: due))"
        }
        return nil
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(project.title)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(project.status.displayTitle)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor.gradient)
                        .clipShape(Capsule())

                    if let jobType = project.jobType {
                        Text(jobType.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let clientName = project.client?.displayName {
                    Label(clientName, systemImage: "person")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let dateRange = dateRangeText {
                    Label(dateRange, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if project.isOverdue {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture { drawerRouter.present(.projectDetail(project)) }
    }

    // MARK: - Colors

    private var statusColor: Color {
        switch project.status {
        case .planning: .blue
        case .inProgress: .green
        case .onHold: .orange
        case .completed: .purple
        case .cancelled: .red
        case .template: .teal
        }
    }
}
