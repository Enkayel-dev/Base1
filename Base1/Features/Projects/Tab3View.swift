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
    @State private var showingAddProject = false

    @Environment(BusinessManager.self) private var businessManager

    @Query(sort: \Project.createdAt, order: .reverse)
    private var allProjects: [Project]

    // MARK: - Business Scope

    private var businessProjects: [Project] {
        guard let key = businessManager.businessKey else { return [] }
        return allProjects.filter { $0.businessKey == key }
    }

    private var filteredProjects: [Project] {
        switch selectedFilter {
        case .all:
            return businessProjects
        case .planning:
            return businessProjects.filter { $0.status == .planning }
        case .inProgress:
            return businessProjects.filter { $0.status == .inProgress }
        case .onHold:
            return businessProjects.filter { $0.status == .onHold }
        case .completed:
            return businessProjects.filter { $0.status == .completed }
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
                    showingAddProject = true
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
        .sheet(isPresented: $showingAddProject) {
            AddProjectView()
        }
    }
}
