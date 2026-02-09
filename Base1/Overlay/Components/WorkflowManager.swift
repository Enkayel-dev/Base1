//
//  WorkflowManager.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI
import Foundation

// MARK: - Workflow Model

struct Workflow: Identifiable, Equatable {
    let id: UUID
    var title: String
    var subtitle: String
    var icon: String
    var iconColor: Color
    var progress: Double // 0.0 ... 1.0
    var status: Status
    var steps: [Step]
    var currentStepIndex: Int
    
    enum Status: String, CaseIterable {
        case idle = "Idle"
        case running = "Running"
        case paused = "Paused"
        case completed = "Completed"
        case failed = "Failed"
        
        var systemImage: String {
            switch self {
            case .idle: "circle.dashed"
            case .running: "play.circle.fill"
            case .paused: "pause.circle.fill"
            case .completed: "checkmark.circle.fill"
            case .failed: "xmark.circle.fill"
            }
        }
        
        var tint: Color {
            switch self {
            case .idle: .secondary
            case .running: .blue
            case .paused: .orange
            case .completed: .green
            case .failed: .red
            }
        }
    }
    
    struct Step: Identifiable, Equatable {
        let id: UUID
        var name: String
        var isComplete: Bool
    }
    
    var currentStepName: String {
        guard steps.indices.contains(currentStepIndex) else { return subtitle }
        return steps[currentStepIndex].name
    }
    
    var isActive: Bool {
        status == .running || status == .paused
    }
    
    static let placeholder = Workflow(
        id: UUID(),
        title: "Data Import",
        subtitle: "Processing records",
        icon: "arrow.triangle.2.circlepath",
        iconColor: .blue,
        progress: 0.3,
        status: .running,
        steps: [
            Step(id: UUID(), name: "Validating input", isComplete: true),
            Step(id: UUID(), name: "Processing records", isComplete: false),
            Step(id: UUID(), name: "Finalizing", isComplete: false)
        ],
        currentStepIndex: 1
    )
}

// MARK: - Workflow Manager

@Observable
final class WorkflowManager {
    var activeWorkflow: Workflow?
    var recentWorkflows: [Workflow] = []
    
    /// Whether there's a workflow worth showing in the mini card
    var hasActiveWorkflow: Bool {
        activeWorkflow?.isActive ?? false
    }
    
    // MARK: - Actions
    
    func togglePause() {
        guard var workflow = activeWorkflow else { return }
        switch workflow.status {
        case .running:
            workflow.status = .paused
        case .paused:
            workflow.status = .running
        default:
            break
        }
        activeWorkflow = workflow
    }
    
    func skip() {
        guard var workflow = activeWorkflow else { return }
        guard workflow.steps.indices.contains(workflow.currentStepIndex) else { return }
        
        workflow.steps[workflow.currentStepIndex].isComplete = true
        
        if workflow.currentStepIndex + 1 < workflow.steps.count {
            workflow.currentStepIndex += 1
            workflow.progress = Double(workflow.currentStepIndex) / Double(workflow.steps.count)
        } else {
            workflow.progress = 1.0
            workflow.status = .completed
        }
        activeWorkflow = workflow
    }
    
    func cancel() {
        guard var workflow = activeWorkflow else { return }
        workflow.status = .idle
        recentWorkflows.insert(workflow, at: 0)
        activeWorkflow = nil
    }
    
    // MARK: - Demo / Placeholder
    
    func loadPlaceholder() {
        activeWorkflow = .placeholder
    }
}
