//
//  Tab3View.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI
import SwiftData

struct Tab3View: View {
    @State private var selectedFilter: ProjectFilterOption = .all

    @Environment(BusinessManager.self) private var businessManager
    @Environment(DrawerRouter.self) private var drawerRouter

    @Query(sort: \Project.createdAt, order: .reverse)
    private var allProjects: [Project]

    // MARK: - Business Scope

    private var businessProjects: [Project] {
        guard let key = businessManager.businessKey else { return [] }
        return allProjects.filter { $0.businessKey == key }
    }
    
    /// Projects visible to the current user based on their role.
    /// Owners and admins see all projects; members see only assigned projects.
    private var visibleProjects: [Project] {
        var projects = businessProjects
        
        // Non-admin members only see projects they're assigned to
        if !businessManager.isOwnerOrAdmin, let member = businessManager.currentMember {
            projects = projects.filter { project in
                project.teamMembers.contains { $0.persistentModelID == member.persistentModelID }
            }
        }
        
        return projects
    }

    private var filteredProjects: [Project] {
        switch selectedFilter {
        case .all:
            return visibleProjects.filter { $0.status != .template }
        case .planning:
            return visibleProjects.filter { $0.status == .planning }
        case .inProgress:
            return visibleProjects.filter { $0.status == .inProgress }
        case .onHold:
            return visibleProjects.filter { $0.status == .onHold }
        case .completed:
            return visibleProjects.filter { $0.status == .completed }
        case .templates:
            // Templates are only visible to owners/admins
            if businessManager.isOwnerOrAdmin {
                return businessProjects.filter { $0.status == .template && $0.jobType?.parent == nil }
            } else {
                return []
            }
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {

            VStack(spacing: 8) {
                Text("Projects")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Button {
                    drawerRouter.present(.addProject)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            LiquidGlassFilterPicker(selectedFilter: $selectedFilter)
                .padding(.horizontal)

            if filteredProjects.isEmpty {
                EmptyProjectsView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredProjects) { project in
                            ProjectRowView(project: project)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }
            }

            Spacer()
        }
    }
}
