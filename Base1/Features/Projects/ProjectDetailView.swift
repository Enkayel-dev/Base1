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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: project.title,
                leadingText: "Back",
                leadingAction: {
                    if project.status == .template, let jt = project.jobType, jt.parent == nil {
                        let service = ProjectService(modelContext: modelContext)
                        service.syncScopeFromParentToVariants(parentTemplateProject: project)
                    }
                    dismiss()
                },
                trailingText: nil,
                trailingAction: nil
            )

            ScrollView {
                VStack(spacing: 24) {
                    projectHeader
                    clientSection
                    assignedTeamSection
                    measurementsSection
                    scopeItemsSection
                    photosSection
                    documentsSection
                    summarySection
                }
                .padding()
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
    }

    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Documents")
                .font(.headline)

            if !project.isLocked {
                Text("No documents generated yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button {
                            drawerRouter.present(.projectEstimate(project))
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.blue)
                                
                                Text("Project Estimate")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                
                                Text(project.updatedAt, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(width: 140, height: 140, alignment: .topLeading)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
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

                if let jobType = project.jobType {
                    Text(jobType.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let description = project.projectDescription {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Start Date", systemImage: "calendar")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    DatePicker("Start", selection: Binding(
                        get: { project.startDate ?? .now },
                        set: { project.startDate = $0 }
                    ), displayedComponents: .date)
                    .labelsHidden()
                    .scaleEffect(0.9)
                    .frame(height: 32)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Label("Due Date", systemImage: "calendar.badge.clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    DatePicker("Due", selection: Binding(
                        get: { project.dueDate ?? .now.addingTimeInterval(86400 * 7) },
                        set: { project.dueDate = $0 }
                    ), displayedComponents: .date)
                    .labelsHidden()
                    .scaleEffect(0.9)
                    .frame(height: 32)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Client Section

    private var clientSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Client")
                .font(.headline)

            if let client = project.client {
                Button {
                    drawerRouter.present(.clientDetail(client))
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(.blue.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text(client.initials)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(client.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            if let company = client.companyName {
                                Text(company)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Text("No client linked")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
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

    // MARK: - Measurements Section

    private var measurementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Measurements")
                    .font(.headline)
                Spacer()
                if !project.isLocked {
                    Button {
                        drawerRouter.present(.addMeasurement(project))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }

            if project.measurements.isEmpty {
                Text("No measurements recorded")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 8) {
                    ForEach(project.measurements.sorted(by: { $0.createdAt > $1.createdAt })) { m in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(m.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                if let notes = m.notes {
                                    Text(notes)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Text("\(m.value as NSDecimalNumber) \(m.unit.abbreviation)")
                                .font(.subheadline)
                                .monospacedDigit()
                        }
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
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

                if !project.isLocked {
                    Button {
                        drawerRouter.present(.addScopeItem(project))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
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

    // MARK: - Site Photos Section

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Site Photos")
                    .font(.headline)
                Spacer()
                if !project.isLocked {
                    Button {
                        drawerRouter.present(.addProjectPhoto(project))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }

            if project.photos.isEmpty {
                Text("No photos uploaded")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(project.photos.sorted(by: { $0.createdAt > $1.createdAt })) { photo in
                            if let data = photo.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                summaryCard(
                    title: "Total Cost",
                    value: formatCurrency(project.totalScopeCost),
                    icon: "dollarsign.circle"
                )

                summaryCard(
                    title: "Labor Hours",
                    value: "\(project.totalLaborHours as NSDecimalNumber)h",
                    icon: "clock"
                )
            }

            HStack(spacing: 12) {
                summaryCard(
                    title: "Materials",
                    value: formatCurrency(project.totalMaterialCost),
                    icon: "shippingbox"
                )

                summaryCard(
                    title: "Labor",
                    value: formatCurrency(project.totalLaborCost),
                    icon: "person"
                )
            }

            if project.totalFixedCost > 0 {
                summaryCard(
                    title: "Fixed Costs",
                    value: formatCurrency(project.totalFixedCost),
                    icon: "dollarsign"
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

            if project.status == .planning && !project.isLocked {
                let isValid = project.client != nil && !project.scopeItems.isEmpty && !project.measurements.isEmpty
                
                Button {
                    lockInProject()
                } label: {
                    HStack {
                        Spacer()
                        if isValid {
                            Image(systemName: "lock.fill")
                        } else {
                            Image(systemName: "exclamationmark.triangle")
                        }
                        Text("Lock in & Prepare Estimate")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    .background(isValid ? Color.blue : Color.secondary.opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!isValid)
                
                if !isValid {
                    Text("Requires Client, Measurement, and Scope Item")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func lockInProject() {
        project.status = .inProgress
        project.isLocked = true
        project.updatedAt = .now
        
        // Create milestone
        if let businessKey = project.business?.businessKey {
            let milestone = ProjectMilestone(
                businessKey: businessKey,
                milestoneType: .estimateSent,
                date: .now
            )
            milestone.project = project
            modelContext.insert(milestone)
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
        case .template: .teal
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}
