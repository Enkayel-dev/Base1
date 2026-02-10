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
    
    // MARK: - Workflow Controls
    
    public func startWorkflow(_ workflow: Workflow) {
        // If not already in context, insert it
        if workflow.modelContext == nil {
            modelContext?.insert(workflow)
        }
        
        activeWorkflow = workflow
        activeWorkflow?.currentStepIndex = 0
        activeWorkflow?.isPaused = false
        activeWorkflow?.isCompleted = false
        save()
    }
    
    public func nextStep() {
        guard let workflow = activeWorkflow else { return }
        guard !workflow.isCompleted else { return }
        
        workflow.currentStepIndex += 1
        
        // Check if finished
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
        workflow.currentStepIndex = workflow.steps.count // Ensure index is at end
        
        // Logic for history is now handled by SwiftData persistence
        // The workflow remains in the database with isCompleted = true
        
        activeWorkflow = nil
        save()
    }
    
    public func cancelWorkflow() {
        guard activeWorkflow != nil else { return }
        // Depending on requirements, we might delete it or mark as cancelled
        // For now, let's just clear active state.
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

