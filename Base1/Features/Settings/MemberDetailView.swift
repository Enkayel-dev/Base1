//
//  MemberDetailView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-15.
//

import SwiftUI
import SwiftData

struct MemberDetailView: View {
    @Bindable var member: Member
    
    @Environment(\.dismissDrawer) private var dismiss
    @Environment(DrawerRouter.self) private var drawerRouter

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: member.displayName,
                leadingText: "Back",
                leadingAction: { dismiss() },
                trailingText: nil,
                trailingAction: nil
            )

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Avatar & Basic Info
                    profileHeader
                    
                    // MARK: - Payroll Info
                    payrollSection
                    
                    // MARK: - Time Tracking
                    timeTrackingSection
                }
                .padding()
                .padding(.bottom, 120)
            }
        }
        .background(Color.clear)
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            Text(member.initials)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(avatarColor.gradient)
                .clipShape(Circle())
                .shadow(radius: 4)

            VStack(spacing: 4) {
                Text(member.displayName)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(member.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(member.role.displayTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(roleBadgeColor.gradient)
                    .clipShape(Capsule())
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var payrollSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Payroll Information", systemImage: "dollarsign.circle")
                .font(.headline)

            VStack(spacing: 0) {
                LabeledTextField("Hourly Rate", value: $member.hourlyRate, icon: "clock.badge.checkmark", format: .currency(code: "USD"))
                Divider()
                LabeledTextField("Bank Name", text: $member.bankName.orEmpty, icon: "building.columns")
                Divider()
                LabeledTextField("Account Number", text: $member.accountNumber.orEmpty, icon: "number")
                Divider()
                LabeledTextField("Transit Number", text: $member.transitNumber.orEmpty, icon: "arrow.left.arrow.right")
                Divider()
                LabeledTextField("SIN / SSN", text: $member.sin.orEmpty, icon: "person.badge.shield.checkered")
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var timeTrackingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Time Tracking", systemImage: "stopwatch")
                    .font(.headline)
                Spacer()
                Text("\(String(format: "%.1f", member.hoursWorked))h total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if member.assignedMilestones.isEmpty {
                Text("No time logged yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 12) {
                    ForEach(member.milestonesByProject.keys.sorted(by: { $0.title < $1.title })) { project in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(project.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                                let projectHours = member.milestonesByProject[project]?.reduce(0.0) { $0 + $1.duration } ?? 0.0
                                Text("\(String(format: "%.1f", projectHours))h")
                                    .font(.caption)
                                    .monospacedDigit()
                            }
                            
                            ForEach(member.milestonesByProject[project]?.sorted(by: { $0.date > $1.date }) ?? []) { milestone in
                                HStack {
                                    milestone.milestoneType.icon
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text(milestone.milestoneType.displayTitle)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(milestone.date, style: .date)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(.thinMaterial.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    private var avatarColor: Color {
        switch member.role {
        case .owner: .blue
        case .admin: .purple
        case .member: .gray
        }
    }

    private var roleBadgeColor: Color {
        switch member.role {
        case .owner: .blue
        case .admin: .purple
        case .member: .gray
        }
    }
}

extension MilestoneType {
    var icon: Image {
        Image(systemName: systemImage)
    }
}
