//
//  WorkflowService.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData
import Observation

// MARK: - Workflow Service

@Observable
public final class WorkflowService {

    // Currently active workflow
    public var activeWorkflow: Workflow?

    // Context for saving changes
    private var modelContext: ModelContext?

    public init() {}

    // Inject context for persistence
    public func setContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Template Instantiation

    /// Creates a new Workflow instance from a template and links it to an optional client/project.
    public func startWorkflow(
        from template: WorkflowTemplate,
        client: Client? = nil,
        project: Project? = nil
    ) {
        let workflow = Workflow(
            title: template.title,
            icon: template.icon,
            iconColor: template.iconColor
        )
        workflow.template = template
        workflow.client = client
        workflow.project = project

        modelContext?.insert(workflow)

        // Copy step templates into workflow step instances
        for stepTemplate in template.sortedStepTemplates {
            let step = WorkflowStep(
                title: stepTemplate.title,
                subtitle: stepTemplate.subtitle,
                viewKey: stepTemplate.viewKey,
                requiresAction: stepTemplate.requiresAction,
                sortOrder: stepTemplate.sortOrder
            )
            workflow.steps.append(step)
        }

        activeWorkflow = workflow
        save()
    }

    // MARK: - Direct Start (for backward compatibility / testing)

    public func startWorkflow(_ workflow: Workflow) {
        if workflow.modelContext == nil {
            modelContext?.insert(workflow)
        }

        activeWorkflow = workflow
        activeWorkflow?.currentStepIndex = 0
        activeWorkflow?.isPaused = false
        activeWorkflow?.isCompleted = false
        save()
    }

    // MARK: - Workflow Controls

    public func nextStep() {
        guard let workflow = activeWorkflow else { return }
        guard !workflow.isCompleted else { return }

        workflow.currentStepIndex += 1

        if workflow.currentStepIndex >= workflow.steps.count {
            completeWorkflow()
        } else {
            save()
        }
    }

    public func skipStep() {
        nextStep()
    }

    public func previousStep() {
        guard let workflow = activeWorkflow else { return }
        guard workflow.currentStepIndex > 0 else { return }

        workflow.currentStepIndex -= 1
        save()
    }

    public func togglePause() {
        guard let workflow = activeWorkflow else { return }
        workflow.isPaused.toggle()
        save()
    }

    public func pauseWorkflow() {
        guard let workflow = activeWorkflow else { return }
        workflow.isPaused = true
        save()
    }

    public func resumeWorkflow() {
        guard let workflow = activeWorkflow else { return }
        workflow.isPaused = false
        save()
    }

    public func completeWorkflow() {
        guard let workflow = activeWorkflow else { return }
        workflow.isCompleted = true
        workflow.currentStepIndex = workflow.steps.count

        activeWorkflow = nil
        save()
    }

    public func cancelWorkflow() {
        guard activeWorkflow != nil else { return }
        activeWorkflow = nil
    }

    private func save() {
        do {
            try modelContext?.save()
        } catch {
            print("Failed to save workflow state: \(error.localizedDescription)")
        }
    }
}
