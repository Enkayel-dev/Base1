//
//  ProjectRowView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct ProjectRowView: View {
    let project: Project

    @Environment(DrawerRouter.self) private var drawerRouter

    private var dateRangeText: String? {
        if let start = project.startDate, let due = project.dueDate {
            return "\(start.formatted(date: .abbreviated, time: .omitted)) – \(due.formatted(date: .abbreviated, time: .omitted))"
        } else if let start = project.startDate {
            return "Started \(start.formatted(date: .abbreviated, time: .omitted))"
        } else if let due = project.dueDate {
            return "Due \(due.formatted(date: .abbreviated, time: .omitted))"
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                drawerRouter.present(.projectDetail(project.persistentModelID))
            } label: {
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
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if project.isLocked {
                Button {
                    drawerRouter.present(.projectEstimate(project.persistentModelID))
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Project Estimate")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            
                            Text(project.updatedAt, style: .date)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(.background.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
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
