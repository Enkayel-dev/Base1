//
//  WorkflowMiniCard.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct WorkflowMiniCard: View {
    @Environment(WorkflowManager.self) private var workflowManager
    @Namespace private var glassNS
    
    private var workflow: Workflow? { workflowManager.activeWorkflow }
    
    var body: some View {
        if let workflow {
            VStack(spacing: 8) {
                // Main row
                HStack(spacing: 12) {
                    // Workflow icon
                    workflowIcon(workflow)
                    
                    // Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(workflow.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(workflow.currentStepName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Controls
                    HStack(spacing: 16) {
                        Button {
                            withAnimation(.spring(response: DesignConstants.Animation.quickResponse)) {
                                workflowManager.togglePause()
                            }
                        } label: {
                            Image(systemName: workflow.status == .running ? "pause.fill" : "play.fill")
                                .font(.title3)
                                .frame(
                                    width: DesignConstants.Settings.buttonSize,
                                    height: DesignConstants.Settings.buttonSize
                                )
                        }
                        .glassEffect(.regular.interactive(), in: .circle)
                        
                        Button {
                            withAnimation(.spring(response: DesignConstants.Animation.quickResponse)) {
                                workflowManager.skip()
                            }
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.title3)
                                .frame(
                                    width: DesignConstants.Settings.buttonSize,
                                    height: DesignConstants.Settings.buttonSize
                                )
                        }
                        .glassEffect(.regular.interactive(), in: .circle)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                // Progress bar
                WorkflowProgressBar(progress: workflow.progress, status: workflow.status)
                    .padding(.horizontal, 4)
            }
        }
    }
    
    @ViewBuilder
    private func workflowIcon(_ workflow: Workflow) -> some View {
        RoundedRectangle(cornerRadius: DesignConstants.WorkflowCard.iconCornerRadius)
            .fill(workflow.iconColor.gradient)
            .frame(
                width: DesignConstants.WorkflowCard.iconSize,
                height: DesignConstants.WorkflowCard.iconSize
            )
            .overlay {
                Image(systemName: workflow.icon)
                    .foregroundStyle(.white)
            }
            .glassEffect(.regular, in: .rect(cornerRadius: 8))
    }
}

// MARK: - Progress Bar

struct WorkflowProgressBar: View {
    let progress: Double
    let status: Workflow.Status
    
    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(.quaternary)
                    .frame(height: DesignConstants.WorkflowCard.progressHeight)
                
                // Filled progress
                Capsule()
                    .fill(status.tint.gradient)
                    .frame(
                        width: trackWidth * progress,
                        height: DesignConstants.WorkflowCard.progressHeight
                    )
                    .animation(.spring(response: 0.4), value: progress)
                
                // Handle
                Circle()
                    .fill(.white)
                    .frame(
                        width: DesignConstants.WorkflowCard.handleSize,
                        height: DesignConstants.WorkflowCard.handleSize
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .offset(x: (trackWidth * progress) - (DesignConstants.WorkflowCard.handleSize / 2))
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
        .frame(height: DesignConstants.WorkflowCard.trackHeight)
    }
}
