//
//  ScopeItemTemplateRowView.swift
//  Base1
//
//  Created by Claude on 2026-02-19.
//

import SwiftUI
import SwiftData

struct ScopeItemTemplateRowView: View {
    let template: ScopeItemTemplate
    
    @Environment(DrawerRouter.self) private var drawerRouter
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Button {
            drawerRouter.present(.editScopeItemTemplate(template.persistentModelID))
        } label: {
            HStack(spacing: 12) {
                // Resource icon
                resourceIcon
                
                // Template info
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 8) {
                        if let resource = template.resource {
                            Text(resource.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let jobType = template.jobType {
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            Text(jobType.name)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                
                Spacer()
                
                // Default values
                VStack(alignment: .trailing, spacing: 4) {
                    if let hours = template.defaultLaborHours {
                        Text("\(hours as NSDecimalNumber)h")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Text("\(template.defaultQuantity as NSDecimalNumber)")
                            .font(.caption)
                            .monospacedDigit()
                        if let unit = template.defaultUnit {
                            Text(unit.abbreviation)
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                deleteTemplate()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Resource Icon
    
    private var resourceIcon: some View {
        let category = template.resource?.category
        let iconName: String
        let color: Color
        
        switch category {
        case .equipment:
            iconName = "wrench.and.screwdriver"
            color = .orange
        case .material:
            iconName = "cube.box"
            color = .blue
        case .vehicle:
            iconName = "car"
            color = .green
        case .tool:
            iconName = "hammer"
            color = .purple
        case nil:
            iconName = "doc.text"
            color = .gray
        }
        
        return Circle()
            .fill(color.opacity(0.1))
            .frame(width: 40, height: 40)
            .overlay {
                Image(systemName: iconName)
                    .font(.subheadline)
                    .foregroundStyle(color)
            }
    }
    
    // MARK: - Actions
    
    private func deleteTemplate() {
        modelContext.delete(template)
    }
}
