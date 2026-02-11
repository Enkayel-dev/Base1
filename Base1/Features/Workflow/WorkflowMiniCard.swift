//
//  WorkflowMiniCard.swift
//  Base1
//
//  Refactored for Swift 6 / SwiftData / Observation
//

import SwiftUI
import Observation

struct WorkflowMiniCard: View {
    
    // MARK: - Injected Workflow Service
    @Environment(WorkflowService.self) private var workflowService
    @Namespace private var glassNS
    
    private var workflow: Workflow? { workflowService.activeWorkflow }
    
    var body: some View {
        if let workflow {
            VStack(spacing: 8) {
                // MARK: - Main Row
                HStack(spacing: 12) {
                    
                    // Workflow Icon
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
                        // Pause / Resume
                        Button {
                            withAnimation(.spring(response: DesignConstants.Animation.quickResponse)) {
                                workflowService.togglePause()
                            }
                        } label: {
                            Image(systemName: workflow.isActive ? "pause.fill" : "play.fill")
                                .font(.title3)
                                .frame(
                                    width: DesignConstants.Settings.buttonSize,
                                    height: DesignConstants.Settings.buttonSize
                                )
                        }
                        .glassEffect(.regular.interactive(), in: .circle)
                        
                        // Skip / Next Step
                        Button {
                            withAnimation(.spring(response: DesignConstants.Animation.quickResponse)) {
                                workflowService.skipStep()
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
                
                // Progress Bar
                WorkflowProgressBar(progress: workflow.progress, status: workflow.status)
                    .padding(.horizontal, 12)
            }
            // Background/Shadow removed to integrate cleanly into BottomBarView
            //.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            //.shadow(radius: 4)
            //.padding(.horizontal)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    // MARK: - Workflow Icon
    
    @ViewBuilder
    private func workflowIcon(_ workflow: Workflow) -> some View {
        Button {
            // Expand workflow details / navigate
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: DesignConstants.WorkflowCard.iconCornerRadius)
                    .fill(workflow.iconColor.gradient)
                
                Image(systemName: workflow.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .frame(
                width: DesignConstants.WorkflowCard.iconSize,
                height: DesignConstants.WorkflowCard.iconSize
            )
        }
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: DesignConstants.WorkflowCard.iconCornerRadius))
        .glassEffectID("workflow-icon", in: glassNS)
    }
}

// MARK: - Progress Bar

struct WorkflowProgressBar: View {
    let progress: Double
    let status: Workflow.Status
    @Namespace private var glassNS
    
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
                    .fill(.ultraThinMaterial)
                    .frame(
                        width: DesignConstants.WorkflowCard.handleSize,
                        height: DesignConstants.WorkflowCard.handleSize
                    )
                    .overlay {
                        Circle()
                            .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .glassEffect(.regular.interactive(), in: .circle)
                    .glassEffectID("progress-handle", in: glassNS)
                    .offset(x: (trackWidth * progress) - (DesignConstants.WorkflowCard.handleSize / 2))
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
        .frame(height: DesignConstants.WorkflowCard.trackHeight)
    }
}
