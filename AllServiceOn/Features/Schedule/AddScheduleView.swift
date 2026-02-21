//
//  AddScheduleView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-15.
//

import SwiftUI
import SwiftData

struct AddScheduleView: View {
    let project: Project
    let milestoneType: MilestoneType
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss
    @Environment(BusinessManager.self) private var businessManager
    
    @Query(sort: \Member.displayName) private var allMembers: [Member]
    
    @State private var selectedMember: Member?
    @State private var startDate: Date
    @State private var endDate: Date?
    @State private var isDurationBased: Bool = false
    @State private var notes: String = ""

    init(project: Project, milestoneType: MilestoneType) {
        self.project = project
        self.milestoneType = milestoneType
        
        // Pre-fill logic: 
        // If it's workStarted, default to project's start date
        // Default time to 8:00 AM today or on project start date
        let calendar = Calendar.current
        let defaultStart = project.startDate ?? .now
        let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: defaultStart) ?? defaultStart
        
        _startDate = State(initialValue: morning)
        _isDurationBased = State(initialValue: milestoneType == .workStarted)
        
        if milestoneType == .workStarted {
            _endDate = State(initialValue: calendar.date(byAdding: .hour, value: 8, to: morning))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Schedule \(milestoneType.displayTitle)",
                leadingText: "Cancel",
                leadingAction: { dismiss() },
                trailingText: "Save",
                trailingAction: saveSchedule
            )

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Project Info (Read-only)
                    VStack(alignment: .leading, spacing: 8) {
                        Label(project.title, systemImage: "folder")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if let client = project.client {
                            Label(client.name, systemImage: "person")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))

                    // MARK: - Member Assignment
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Assign Team Member")
                            .font(.headline)
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(allMembers) { member in
                                    memberPickerItem(member: member)
                                }
                            }
                        }
                        .scrollIndicators(.never)
                    }

                    // MARK: - Date & Time
                    VStack(alignment: .leading, spacing: 12) {
                        Text("When")
                            .font(.headline)
                        
                        VStack(spacing: 0) {
                            DatePicker("Start Time", selection: $startDate)
                                .padding()
                            
                            Toggle("Duration based event", isOn: $isDurationBased)
                                .padding()
                            
                            if isDurationBased {
                                Divider()
                                DatePicker("End Time", selection: Binding(
                                    get: { endDate ?? startDate.addingTimeInterval(3600) },
                                    set: { endDate = $0 }
                                ))
                                .padding()
                            }
                        }
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                    }

                    // MARK: - Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.headline)
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .padding(8)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                    }
                }
                .padding()
                .padding(.bottom, 120)
            }
        }
        .background(Color.clear)
        .onAppear {
            // Find existing milestone if any to pre-populate member
            if let existing = project.milestones.first(where: { $0.milestoneType == milestoneType }) {
                selectedMember = existing.assignedMember
                startDate = existing.date
                endDate = existing.endDate
                isDurationBased = existing.endDate != nil
                notes = existing.notes ?? ""
            }
        }
    }

    private func memberPickerItem(member: Member) -> some View {
        let isSelected = selectedMember?.id == member.id
        
        return Button {
            selectedMember = member
        } label: {
            VStack(spacing: 8) {
                Text(member.initials)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(avatarColor(for: member).gradient)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.blue, lineWidth: isSelected ? 3 : 0)
                    )
                
                Text(member.displayName.split(separator: " ").first ?? "")
                    .font(.caption2)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private func saveSchedule() {
        guard let businessKey = businessManager.currentBusiness?.businessKey else { return }
        
        // Check if milestone already exists
        if let existing = project.milestones.first(where: { $0.milestoneType == milestoneType }) {
            existing.date = startDate
            existing.endDate = isDurationBased ? endDate : nil
            existing.assignedMember = selectedMember
            existing.notes = notes.isEmpty ? nil : notes
        } else {
            let newMilestone = ProjectMilestone(
                businessKey: businessKey,
                milestoneType: milestoneType,
                date: startDate,
                notes: notes.isEmpty ? nil : notes
            )
            newMilestone.endDate = isDurationBased ? endDate : nil
            newMilestone.assignedMember = selectedMember
            newMilestone.project = project
            modelContext.insert(newMilestone)
        }
        
        dismiss()
    }

    private func avatarColor(for member: Member) -> Color {
        switch member.role {
        case .owner: .blue
        case .admin: .purple
        case .member: .gray
        }
    }
}
