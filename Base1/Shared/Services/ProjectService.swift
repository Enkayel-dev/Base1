//
//  ProjectService.swift
//  Base1
//
//  Created by Antigravity on 2026-02-12.
//

import Foundation
import SwiftData

@MainActor
public final class ProjectService {
    
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Deep copies a template project into a new project.
    /// - Parameters:
    ///   - template: The template project to copy from.
    ///   - target: The new project to copy data into.
    public func duplicateTemplate(from template: Project, to target: Project) {
        let businessKey = target.businessKey
        
        // 1. Duplicate Scope Items
        for item in template.scopeItems {
            let newItem = ScopeItem(
                businessKey: businessKey,
                laborHours: item.laborHours,
                fixedCost: item.fixedCost,
                costMarkup: item.costMarkup,
                description: item.itemDescription
            )
            newItem.project = target
            modelContext.insert(newItem)
            
            // Duplicate Resources for each Scope Item
            for sir in item.scopeItemResources {
                let newSir = ScopeItemResource(
                    businessKey: businessKey,
                    quantity: sir.quantity,
                    unit: sir.unit
                )
                newSir.resource = sir.resource
                newSir.scopeItem = newItem
                modelContext.insert(newSir)
            }
        }
        
        // 2. Duplicate Measurements ONLY if the target doesn't have any
        // (Variants should keep their unique measurements)
        if target.measurements.isEmpty {
            for measurement in template.measurements {
                let newMeasurement = ProjectMeasurement(
                    businessKey: businessKey,
                    name: measurement.name,
                    value: measurement.value,
                    unit: measurement.unit,
                    notes: measurement.notes
                )
                newMeasurement.project = target
                modelContext.insert(newMeasurement)
            }
        }
        
        // 3. Duplicate Photos
        for photo in template.photos {
            let newPhoto = ProjectPhoto(
                businessKey: businessKey,
                imageData: photo.imageData,
                caption: photo.caption
            )
            newPhoto.project = target
            modelContext.insert(newPhoto)
        }
    }
    
    /// Synchronizes scope items from a parent template to all its variant templates.
    public func syncScopeFromParentToVariants(parentTemplateProject: Project) {
        guard let parentJobType = parentTemplateProject.jobType, parentJobType.parent == nil else { return }
        
        
        // Find all child job types that have template projects
        for childJobType in parentJobType.children {
            guard let variantTemplate = childJobType.templateProject else { continue }
            
            // Clear existing scope items in the variant to ensure sync
            // (Only if it's a template; regular projects shouldn't be auto-synced this way)
            for item in variantTemplate.scopeItems {
                modelContext.delete(item)
            }
            
            // Copy scope from parent to this variant
            duplicateTemplate(from: parentTemplateProject, to: variantTemplate)
        }
    }
}
