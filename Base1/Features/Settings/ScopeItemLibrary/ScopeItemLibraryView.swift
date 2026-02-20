//
//  ScopeItemLibraryView.swift
//  Base1
//
//  Created by Claude on 2026-02-19.
//

import SwiftUI
import SwiftData

struct ScopeItemLibraryView: View {
    @Environment(BusinessManager.self) private var businessManager
    @Environment(DrawerRouter.self) private var drawerRouter
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss
    
    @Query(sort: \ScopeItemTemplate.name) private var allTemplates: [ScopeItemTemplate]
    @Query(sort: \JobType.sortOrder) private var allJobTypes: [JobType]
    
    @State private var selectedJobType: JobType?
    @State private var showAllJobTypes = true
    @State private var searchText = ""
    
    private var filteredTemplates: [ScopeItemTemplate] {
        guard let key = businessManager.businessKey else { return [] }
        var templates = allTemplates.filter { $0.businessKey == key }
        
        // Filter by job type
        if !showAllJobTypes, let jobType = selectedJobType {
            templates = templates.filter { $0.jobType?.persistentModelID == jobType.persistentModelID }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            templates = templates.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.resource?.name.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return templates
    }
    
    private var businessJobTypes: [JobType] {
        guard let key = businessManager.businessKey else { return [] }
        return allJobTypes.filter { $0.businessKey == key && $0.parent == nil }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Scope Item Library",
                leadingAction: { dismiss() },
                trailingText: "Add",
                trailingAction: { drawerRouter.present(.addScopeItemTemplate) }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search templates...", text: $searchText)
                    }
                    .padding(12)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                    
                    // Job Type Filter
                    jobTypeFilter
                    
                    // Templates List
                    if filteredTemplates.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredTemplates) { template in
                                ScopeItemTemplateRowView(template: template)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
    }
    
    // MARK: - Job Type Filter
    
    private var jobTypeFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                // "All" chip
                filterChip(label: "All", icon: "list.bullet", isSelected: showAllJobTypes) {
                    showAllJobTypes = true
                    selectedJobType = nil
                }
                
                ForEach(businessJobTypes) { jobType in
                    filterChip(label: jobType.name, icon: jobType.icon, isSelected: !showAllJobTypes && selectedJobType?.persistentModelID == jobType.persistentModelID) {
                        showAllJobTypes = false
                        selectedJobType = jobType
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .scrollIndicators(.never)
    }
    
    private func filterChip(label: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(
                response: DesignConstants.Animation.morphResponse,
                dampingFraction: DesignConstants.Animation.morphDamping
            )) {
                action()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .background(.thinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Templates")
                .font(.headline)
            
            Text("Create reusable scope item templates to speed up project setup.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                drawerRouter.present(.addScopeItemTemplate)
            } label: {
                Label("Create Template", systemImage: "plus")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }
}
