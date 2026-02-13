//
//  Base1SchemaV1.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftData

enum Base1SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Business.self,
            Client.self,
            Project.self,
            Appointment.self,
            Resource.self,
            Invoice.self,
            WorkflowTemplate.self,
            WorkflowStepTemplate.self,
            Workflow.self,
            WorkflowStep.self,
            ScopeItem.self,
            ScopeItemResource.self,
            Member.self,
            JobType.self,
            ScopeItemTemplate.self,
            ProjectMeasurement.self,
            ProjectPhoto.self,
            ProjectMilestone.self,
        ]
    }
}

enum Base1MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [Base1SchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
